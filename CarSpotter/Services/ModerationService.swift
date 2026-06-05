import Foundation
import FirebaseAuth

/// UGC moderation — single source of truth for App Store Guideline 1.2
/// compliance: a persistent block list, a report queue written to
/// Firestore `/reports`, and a lightweight pre-publish text filter.
///
/// Apple requires apps with user-generated content to provide a way to
/// (a) report objectionable content, (b) block abusive users, and
/// (c) filter objectionable material. This service backs all three.
@MainActor
final class ModerationService: ObservableObject {
    static let shared = ModerationService()

    /// UIDs the current user has blocked. Their posts are hidden from the
    /// feed and they cannot be seen again until unblocked.
    @Published private(set) var blockedUserIds: Set<String> = []

    /// Post IDs the user has reported this session — used to immediately
    /// hide a reported post even before the 24h moderation SLA kicks in.
    @Published private(set) var hiddenPostIds: Set<String> = []

    private let blockKey = "carspotter.blockedUserIds"

    private init() {
        let stored = UserDefaults.standard.stringArray(forKey: blockKey) ?? []
        blockedUserIds = Set(stored)
    }

    // MARK: - Blocking

    func isBlocked(_ userId: String) -> Bool { blockedUserIds.contains(userId) }

    func block(userId: String) {
        guard !userId.isEmpty else { return }
        blockedUserIds.insert(userId)
        persistBlocks()
    }

    func unblock(userId: String) {
        blockedUserIds.remove(userId)
        persistBlocks()
    }

    private func persistBlocks() {
        UserDefaults.standard.set(Array(blockedUserIds), forKey: blockKey)
    }

    // MARK: - Reporting

    enum ReportReason: String, CaseIterable, Identifiable {
        case spam            = "Spam or misleading"
        case offensive       = "Offensive or hateful"
        case sexual          = "Sexual content"
        case violence        = "Violence or threats"
        case harassment      = "Harassment or bullying"
        case other           = "Something else"
        var id: String { rawValue }
    }

    /// Files a report into Firestore `/reports`. Picked up by the
    /// moderation review queue (24h SLA). Also hides the post locally so
    /// the reporter never sees it again.
    func report(post: FeedPost, reason: ReportReason) async {
        hiddenPostIds.insert(post.id)
        let reporterId = Auth.auth().currentUser?.uid ?? "anonymous"
        let data: [String: Any] = [
            "postId": post.id,
            "authorId": post.userId,
            "authorName": post.displayName,
            "reporterId": reporterId,
            "reason": reason.rawValue,
            "caption": post.caption,
            "photoUrl": post.photoUrl,
            "status": "pending",
            "createdAt": Date(),
        ]
        do {
            try await FirestoreREST.createDoc(in: "reports", data: data)
        } catch {
            // Even if the write fails, the post stays hidden locally so the
            // user is protected. Log for diagnostics.
            print("[ModerationService] report write failed: \(error)")
        }
    }

    // MARK: - Pre-publish text filter

    /// A conservative client-side profanity / slur gate run before a post is
    /// uploaded. This is a first line of defense; the server runs the full
    /// OpenAI moderation pass on caption + image. Returns the matched term
    /// when the text should be blocked, or nil when it's clean.
    func firstBlockedTerm(in text: String) -> String? {
        let lowered = " " + text.lowercased()
            .folding(options: .diacriticInsensitive, locale: .current) + " "
        for term in Self.blockedTerms where lowered.contains(term) {
            return term.trimmingCharacters(in: .whitespaces)
        }
        return nil
    }

    func isClean(_ text: String) -> Bool { firstBlockedTerm(in: text) == nil }

    /// Padded with spaces so we match whole words, not substrings (avoids the
    /// Scunthorpe problem). Kept intentionally short; the server is the
    /// authority. Slurs omitted from source comments deliberately.
    private static let blockedTerms: [String] = [
        " nigger ", " nigga ", " faggot ", " fag ", " retard ", " retarded ",
        " kike ", " spic ", " chink ", " coon ", " tranny ", " cunt ",
        " rape ", " rapist ", " kys ", " kill yourself ", " child porn ",
        " cp ", " pedophile ", " pedo ",
    ]
}
