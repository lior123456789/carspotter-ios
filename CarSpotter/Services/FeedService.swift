import Foundation
import UIKit
import FirebaseAuth

/// Real feed service backed by Firestore /posts (read) + Firebase Storage
/// (image upload). Accessed via REST so no heavy native SDKs needed.
@MainActor
final class FeedService: ObservableObject {
    @Published var posts: [FeedPost] = []
    @Published var isLoading = false
    @Published var isPosting = false
    @Published var error: String?

    private var refreshTask: Task<Void, Never>?

    func startListening() {
        refreshTask?.cancel()
        refreshTask = Task { [weak self] in
            while !Task.isCancelled {
                await self?.refresh()
                try? await Task.sleep(nanoseconds: 15_000_000_000)
            }
        }
    }
    func stopListening() { refreshTask?.cancel() }

    /// Pulls the latest 50 posts from Firestore /posts (public read).
    /// Works even when the user isn't signed in.
    func refresh() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let docs = try await FirestoreREST.listDocs(
                in: "posts",
                limit: 50,
                orderByField: "createdAt",
                descending: true,
                requireAuth: false   // /posts is public-read
            )
            let myUid = Auth.auth().currentUser?.uid ?? ""
            let mod = ModerationService.shared
            posts = docs.compactMap { d -> FeedPost? in
                let data = d.data
                // UGC compliance: hide posts from blocked users + reported posts.
                if mod.hiddenPostIds.contains(d.id) { return nil }
                guard let userId = data["userId"] as? String,
                      !mod.isBlocked(userId),
                      let displayName = data["displayName"] as? String,
                      let photoUrl = data["photoUrl"] as? String,
                      let make = data["make"] as? String,
                      let model = data["model"] as? String else { return nil }

                let likedByAny = (data["likedBy"] as? [Any]) ?? []
                let likedByStrings = likedByAny.compactMap { $0 as? String }

                return FeedPost(
                    id: d.id,
                    userId: userId,
                    displayName: displayName,
                    avatarUrl: (data["avatarUrl"] as? String).flatMap { $0.isEmpty ? nil : $0 },
                    photoUrl: photoUrl,
                    make: make,
                    model: model,
                    year: data["year"] as? String ?? "",
                    category: data["category"] as? String ?? "Daily",
                    rarity: data["rarity"] as? Int ?? 5,
                    valueRange: data["valueRange"] as? String ?? "—",
                    caption: data["caption"] as? String ?? "",
                    location: (data["location"] as? String).flatMap { $0.isEmpty ? nil : $0 },
                    createdAt: (data["createdAt"] as? Date) ?? Date(),
                    likeCount: likedByStrings.count,
                    likedByMe: likedByStrings.contains(myUid),
                    likedBy: likedByStrings
                )
            }
        } catch {
            self.error = error.localizedDescription
            print("[FeedService] refresh error: \(error)")
        }
    }

    /// Upload image to Firebase Storage + write post doc to Firestore.
    func createPost(
        imageData: Data,
        car: CarInfo,
        caption: String,
        location: String?
    ) async throws {
        guard let user = Auth.auth().currentUser else {
            throw NSError(domain: "Feed", code: 401,
                          userInfo: [NSLocalizedDescriptionKey: "Sign in to post."])
        }
        // UGC compliance: pre-publish moderation on the caption.
        if let term = ModerationService.shared.firstBlockedTerm(in: caption) {
            print("[FeedService] caption blocked on term: \(term)")
            throw NSError(domain: "Feed", code: 422,
                          userInfo: [NSLocalizedDescriptionKey:
                            "Your caption violates our content guidelines. Please revise it and try again."])
        }
        isPosting = true
        defer { isPosting = false }

        // 1. Upload image to Storage
        let postId = UUID().uuidString
        let imagePath = "posts/\(user.uid)/\(postId).jpg"
        let downloadURL = try await StorageREST.upload(data: imageData, to: imagePath)

        // 2. Write post doc
        let displayName: String = {
            if let n = user.displayName, !n.isEmpty { return n }
            if let e = user.email { return e.components(separatedBy: "@").first ?? "Anonymous" }
            return "Anonymous"
        }()

        let postData: [String: Any] = [
            "userId": user.uid,
            "displayName": displayName,
            "avatarUrl": user.photoURL?.absoluteString ?? "",
            "photoUrl": downloadURL.absoluteString,
            "make": car.make,
            "model": car.model,
            "year": car.year,
            "category": car.category,
            "rarity": car.rarity,
            "valueRange": car.valueRange,
            "caption": caption,
            "location": location ?? "",
            "likedBy": [String](),
            "createdAt": Date(),
        ]
        try await FirestoreREST.createDoc(in: "posts", data: postData)
        await refresh()
    }

    /// Optimistic like toggle.
    func toggleLike(_ post: FeedPost) async {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        // Optimistic UI
        if let idx = posts.firstIndex(where: { $0.id == post.id }) {
            posts[idx].likedByMe.toggle()
            posts[idx].likeCount += posts[idx].likedByMe ? 1 : -1
        }

        let nowLiked = !post.likedByMe
        do {
            // Append/remove ourselves from likedBy array
            let newLikedBy: [String]
            if nowLiked {
                newLikedBy = post.likedBy.contains(uid) ? post.likedBy : post.likedBy + [uid]
            } else {
                newLikedBy = post.likedBy.filter { $0 != uid }
            }
            try await FirestoreREST.setDoc(path: "posts/\(post.id)", data: ["likedBy": newLikedBy])
        } catch {
            // Roll back optimistic update
            if let idx = posts.firstIndex(where: { $0.id == post.id }) {
                posts[idx].likedByMe.toggle()
                posts[idx].likeCount += posts[idx].likedByMe ? 1 : -1
            }
            self.error = error.localizedDescription
        }
    }

    /// Report a post (UGC compliance). Files to the moderation queue and
    /// removes it from the feed immediately.
    func report(_ post: FeedPost, reason: ModerationService.ReportReason) async {
        await ModerationService.shared.report(post: post, reason: reason)
        posts.removeAll { $0.id == post.id }
    }

    /// Block a post's author (UGC compliance). Hides all of their posts.
    func block(_ post: FeedPost) {
        ModerationService.shared.block(userId: post.userId)
        posts.removeAll { $0.userId == post.userId }
    }

    func delete(_ post: FeedPost) async throws {
        guard let uid = Auth.auth().currentUser?.uid, uid == post.userId else { return }
        try await FirestoreREST.deleteDoc(path: "posts/\(post.id)")
        await refresh()
    }
}
