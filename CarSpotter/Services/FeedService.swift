import Foundation
import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

@MainActor
final class FeedService: ObservableObject {
    @Published var posts: [FeedPost] = []
    @Published var isLoading = false
    @Published var isPosting = false
    @Published var error: String?

    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    private var listener: ListenerRegistration?

    deinit { listener?.remove() }

    // ── Live-subscribe to the global feed ──

    func startListening() {
        listener?.remove()
        isLoading = true

        let q = db.collection("posts")
            .order(by: "createdAt", descending: true)
            .limit(to: 100)

        listener = q.addSnapshotListener { [weak self] snap, error in
            Task { @MainActor in
                guard let self else { return }
                self.isLoading = false
                if let error {
                    self.error = error.localizedDescription
                    return
                }
                guard let docs = snap?.documents else { return }
                let uid = Auth.auth().currentUser?.uid ?? ""
                self.posts = docs.compactMap { FeedPost.from(doc: $0, currentUserId: uid) }
            }
        }
    }

    func stopListening() {
        listener?.remove()
        listener = nil
    }

    // ── Create a post ──

    /// Uploads the photo to Firebase Storage, then writes the post doc.
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

        isPosting = true
        defer { isPosting = false }

        let postId = UUID().uuidString
        let path = "posts/\(user.uid)/\(postId).jpg"
        let ref = storage.reference().child(path)

        // 1. Upload photo
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        _ = try await ref.putDataAsync(imageData, metadata: metadata)
        let url = try await ref.downloadURL()

        // 2. Write post doc
        let docData: [String: Any] = [
            "userId": user.uid,
            "displayName": user.displayName ?? user.email?.components(separatedBy: "@").first ?? "Anonymous",
            "avatarUrl": user.photoURL?.absoluteString ?? "",
            "photoUrl": url.absoluteString,
            "make": car.make,
            "model": car.model,
            "year": car.year,
            "category": car.category,
            "rarity": car.rarity,
            "valueRange": car.valueRange,
            "caption": caption,
            "location": location ?? NSNull(),
            "likedBy": [],
            "createdAt": FieldValue.serverTimestamp(),
        ]
        try await db.collection("posts").document(postId).setData(docData)
    }

    // ── Like / unlike ──

    func toggleLike(_ post: FeedPost) async {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        // Optimistic UI
        if let idx = posts.firstIndex(where: { $0.id == post.id }) {
            posts[idx].likedByMe.toggle()
            posts[idx].likeCount += posts[idx].likedByMe ? 1 : -1
        }

        let ref = db.collection("posts").document(post.id)
        let op: FieldValue = post.likedByMe
            ? FieldValue.arrayRemove([uid])
            : FieldValue.arrayUnion([uid])

        do {
            try await ref.updateData(["likedBy": op])
        } catch {
            // Roll back optimistic update
            if let idx = posts.firstIndex(where: { $0.id == post.id }) {
                posts[idx].likedByMe.toggle()
                posts[idx].likeCount += posts[idx].likedByMe ? 1 : -1
            }
            self.error = error.localizedDescription
        }
    }

    // ── Delete (own posts only) ──

    func delete(_ post: FeedPost) async throws {
        guard let uid = Auth.auth().currentUser?.uid, uid == post.userId else { return }
        try await db.collection("posts").document(post.id).delete()
    }
}
