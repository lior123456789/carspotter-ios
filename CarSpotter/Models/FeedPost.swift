import Foundation
import FirebaseFirestore

/// A single car-spot shared to the global feed.
struct FeedPost: Identifiable, Equatable {
    let id: String
    let userId: String
    let displayName: String
    let avatarUrl: String?

    let photoUrl: String           // Firebase Storage download URL
    let make: String
    let model: String
    let year: String
    let category: String
    let rarity: Int
    let valueRange: String

    let caption: String
    let location: String?
    let createdAt: Date
    var likeCount: Int
    var likedByMe: Bool

    static func from(doc: QueryDocumentSnapshot, currentUserId: String) -> FeedPost? {
        let d = doc.data()
        guard
            let userId = d["userId"] as? String,
            let displayName = d["displayName"] as? String,
            let photoUrl = d["photoUrl"] as? String,
            let make = d["make"] as? String,
            let model = d["model"] as? String,
            let createdTs = d["createdAt"] as? Timestamp
        else { return nil }

        let likedBy = (d["likedBy"] as? [String]) ?? []

        return FeedPost(
            id: doc.documentID,
            userId: userId,
            displayName: displayName,
            avatarUrl: d["avatarUrl"] as? String,
            photoUrl: photoUrl,
            make: make,
            model: model,
            year: d["year"] as? String ?? "",
            category: d["category"] as? String ?? "Daily",
            rarity: d["rarity"] as? Int ?? 5,
            valueRange: d["valueRange"] as? String ?? "—",
            caption: d["caption"] as? String ?? "",
            location: d["location"] as? String,
            createdAt: createdTs.dateValue(),
            likeCount: likedBy.count,
            likedByMe: likedBy.contains(currentUserId)
        )
    }

    /// "2m ago" / "3h ago" / "Yesterday" / formatted date
    var timeAgo: String {
        let s = Int(Date().timeIntervalSince(createdAt))
        if s < 60          { return "Just now" }
        if s < 3_600       { return "\(s/60)m ago" }
        if s < 86_400      { return "\(s/3_600)h ago" }
        if s < 86_400 * 2  { return "Yesterday" }
        if s < 86_400 * 7  { return "\(s/86_400)d ago" }
        let f = DateFormatter()
        f.dateFormat = "MMM d"
        return f.string(from: createdAt)
    }
}
