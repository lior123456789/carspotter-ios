import Foundation

/// A single car-spot shared to the global feed.
struct FeedPost: Identifiable, Equatable {
    let id: String
    let userId: String
    let displayName: String
    let avatarUrl: String?

    let photoUrl: String
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
    /// Full list of UIDs that liked this post (used for optimistic toggle math).
    var likedBy: [String] = []

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
