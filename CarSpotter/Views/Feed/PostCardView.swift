import SwiftUI

struct PostCardView: View {
    let post: FeedPost
    let onLike: () -> Void
    let onDelete: (() -> Void)?

    @State private var pressed = false
    @State private var loadedImage: UIImage?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // ── Header row ──
            HStack(spacing: 10) {
                avatar
                VStack(alignment: .leading, spacing: 2) {
                    Text(post.displayName)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                    HStack(spacing: 4) {
                        Text(post.timeAgo)
                            .font(.system(size: 11, design: .rounded))
                            .foregroundStyle(Color.spotterMute)
                        if let loc = post.location {
                            Text("·").foregroundStyle(Color.spotterMute)
                            Image(systemName: "mappin.circle.fill").font(.system(size: 9))
                            Text(loc).font(.system(size: 11, design: .rounded))
                        }
                    }
                    .foregroundStyle(Color.spotterMute)
                }
                Spacer()
                if let onDelete {
                    Menu {
                        Button(role: .destructive) { onDelete() } label: {
                            Label("Delete post", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(Color.spotterMute)
                            .padding(8)
                    }
                }
            }
            .padding(12)

            // ── Hero photo ──
            ZStack(alignment: .bottomLeading) {
                AsyncImage(url: URL(string: post.photoUrl)) { phase in
                    switch phase {
                    case .empty:
                        Rectangle().fill(Color.spotterPanel)
                            .overlay(ProgressView().tint(Color.spotterCyan))
                    case .success(let img):
                        img.resizable().scaledToFill()
                    case .failure:
                        Rectangle().fill(Color.spotterPanel)
                            .overlay(Image(systemName: "photo.fill").foregroundStyle(Color.spotterMute))
                    @unknown default:
                        Rectangle().fill(Color.spotterPanel)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 320)
                .clipped()

                LinearGradient(colors: [.clear, .black.opacity(0.75)],
                               startPoint: .center, endPoint: .bottom)

                // Car info overlay
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        BadgePill(label: post.category, color: .spotterCyan)
                        if post.rarity >= 8 {
                            BadgePill(label: "Rare \(post.rarity)/10",
                                      icon: "trophy.fill", color: .yellow)
                        }
                    }
                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text("\(post.year)").font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundStyle(.white.opacity(0.7))
                        Text("\(post.make) \(post.model)")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .lineLimit(2)
                    }
                    Text(post.valueRange)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(LinearGradient.spotterBrand)
                }
                .padding(14)
            }

            // ── Caption + actions ──
            VStack(alignment: .leading, spacing: 10) {
                if !post.caption.isEmpty {
                    Text(post.caption)
                        .font(.system(size: 14, design: .rounded))
                        .foregroundStyle(.white.opacity(0.85))
                        .lineSpacing(2)
                        .padding(.top, 4)
                }
                HStack(spacing: 18) {
                    Button(action: {
                        let g = UIImpactFeedbackGenerator(style: .light); g.impactOccurred()
                        onLike()
                    }) {
                        HStack(spacing: 5) {
                            Image(systemName: post.likedByMe ? "heart.fill" : "heart")
                                .foregroundStyle(post.likedByMe ? .red : .white)
                            Text("\(post.likeCount)")
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundStyle(.white)
                                .contentTransition(.numericText())
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.spotterPanel)
                        .overlay(Capsule().stroke(Color.spotterLine))
                        .clipShape(Capsule())
                    }
                    .scaleEffect(pressed ? 0.94 : 1)
                    .animation(.spring(response: 0.25, dampingFraction: 0.6), value: pressed)

                    Spacer()

                    ShareLink(item: URL(string: post.photoUrl) ?? URL(string: "https://carsspotter.com")!,
                              subject: Text("\(post.year) \(post.make) \(post.model)")) {
                        HStack(spacing: 5) {
                            Image(systemName: "square.and.arrow.up")
                            Text("Share").font(.system(size: 13, weight: .semibold, design: .rounded))
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.spotterPanel)
                        .overlay(Capsule().stroke(Color.spotterLine))
                        .clipShape(Capsule())
                    }
                }
            }
            .padding(12)
        }
        .background(Color.spotterPanel.opacity(0.5))
        .overlay(RoundedRectangle(cornerRadius: 22).stroke(Color.spotterLine))
        .clipShape(RoundedRectangle(cornerRadius: 22))
    }

    @ViewBuilder private var avatar: some View {
        if let urlStr = post.avatarUrl, !urlStr.isEmpty, let url = URL(string: urlStr) {
            AsyncImage(url: url) { img in
                img.resizable().scaledToFill()
            } placeholder: {
                LinearGradient.spotterBrand
            }
            .frame(width: 36, height: 36)
            .clipShape(Circle())
        } else {
            ZStack {
                LinearGradient.spotterBrand
                Text(post.displayName.prefix(1).uppercased())
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }
            .frame(width: 36, height: 36)
            .clipShape(Circle())
        }
    }
}
