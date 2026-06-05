import Foundation
import UIKit
import FirebaseAuth

/// Web-API-backed feed service. Uses /api/feed for read + /api/feed/post
/// for write. No Firebase Storage SDK needed — server uploads to its own
/// storage bucket and returns a URL.
@MainActor
final class FeedService: ObservableObject {
    @Published var posts: [FeedPost] = []
    @Published var isLoading = false
    @Published var isPosting = false
    @Published var error: String?

    func startListening() {
        Task { await refresh() }
    }
    func stopListening() {}

    func refresh() async {
        isLoading = true
        defer { isLoading = false }
        do {
            var req = URLRequest(url: API.url(.spots))  // placeholder until /api/feed exists
            if let token = try? await Auth.auth().currentUser?.getIDToken() {
                req.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
            let (data, _) = try await URLSession.shared.data(for: req)
            _ = data
        } catch {
            self.error = error.localizedDescription
        }
    }

    func createPost(imageData: Data, car: CarInfo, caption: String, location: String?) async throws {
        guard Auth.auth().currentUser != nil else {
            throw NSError(domain: "Feed", code: 401,
                          userInfo: [NSLocalizedDescriptionKey: "Sign in to post."])
        }
        isPosting = true
        do { isPosting = false }
        // TODO: POST to /api/feed/post with multipart form (image + json)
    }

    func toggleLike(_ post: FeedPost) async {
        if let idx = posts.firstIndex(where: { $0.id == post.id }) {
            posts[idx].likedByMe.toggle()
            posts[idx].likeCount += posts[idx].likedByMe ? 1 : -1
        }
    }

    func delete(_ post: FeedPost) async throws {
        // TODO: DELETE /api/feed/{id}
    }
}
