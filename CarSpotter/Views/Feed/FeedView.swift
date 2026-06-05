import SwiftUI
import FirebaseAuth

struct FeedView: View {
    @StateObject private var feed = FeedService()

    var body: some View {
        NavigationStack {
            ZStack {
                Color.spotterInk.ignoresSafeArea()

                if feed.isLoading && feed.posts.isEmpty {
                    ProgressView().tint(Color.spotterCyan)
                } else if feed.posts.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        LazyVStack(spacing: 14) {
                            ForEach(feed.posts) { post in
                                let isMine = post.userId == (Auth.auth().currentUser?.uid ?? "")
                                PostCardView(post: post,
                                             onLike: { Task { await feed.toggleLike(post) } },
                                             onDelete: isMine
                                                ? { Task { try? await feed.delete(post) } }
                                                : nil,
                                             onReport: isMine ? nil
                                                : { reason in Task { await feed.report(post, reason: reason) } },
                                             onBlock: isMine ? nil
                                                : { feed.block(post) })
                                    .transition(.opacity)
                            }
                        }
                        .padding(.horizontal, 14)
                        .padding(.top, 10)
                        .padding(.bottom, 30)
                        .animation(.easeOut, value: feed.posts.count)
                    }
                }
            }
            .navigationTitle("Feed")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    BadgePill(label: "Live", icon: "dot.radiowaves.left.and.right",
                              color: .spotterCyan)
                }
            }
        }
        .onAppear { feed.startListening() }
        .onDisappear { feed.stopListening() }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "newspaper.fill")
                .font(.system(size: 56))
                .foregroundStyle(LinearGradient.spotterBrand)
                .opacity(0.5)
            Text("The feed is quiet")
                .font(.spotterTitle)
                .foregroundStyle(.white)
            Text("Be the first to share a spot today —\ntag #DailyChallenge for bonus points.")
                .multilineTextAlignment(.center)
                .font(.system(size: 14, design: .rounded))
                .foregroundStyle(Color.spotterMute)
                .padding(.horizontal, 40)
            Spacer()
        }
    }
}

#Preview { FeedView() }
