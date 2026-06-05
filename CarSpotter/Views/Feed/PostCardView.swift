import SwiftUI

struct PostCardView: View {
    let post: FeedPost
    let onLike: () -> Void
    let onDelete: (() -> Void)?

    @State private var pressed = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // ── Header: avatar + username + time + location ──
            HStack(spacing: 10) {
                avatar
                VStack(alignment: .leading, spacing: 2) {
                    Text("@" + post.displayName)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    HStack(spacing: 4) {
                        Text(post.timeAgo)
                            .font(.system(size: 11, design: .rounded))
                        if let loc = post.location {
                            Text("·")
                            Image(systemName: "mappin.circle.fill").font(.system(size: 9))
                            Text(loc).font(.system(size: 11, design: .rounded)).lineLimit(1)
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

            // ── Hero photo (no overlay — clean) ──
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
            .frame(height: 280)
            .clipped()

            // ── Car info row (BELOW the image, no overflow possible) ──
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    BadgePill(label: post.category, color: .spotterCyan)
                    if post.rarity >= 8 {
                        BadgePill(label: "Rare \(post.rarity)/10",
                                  icon: "trophy.fill", color: .yellow)
                    }
                    Spacer(minLength: 0)
                }

                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text(post.year)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.7))
                    Text("\(post.make) \(post.model)")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                    Spacer(minLength: 0)
                }

                Text(post.valueRange)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(LinearGradient.spotterBrand)
                    .lineLimit(1)

                if !post.caption.isEmpty {
                    Text(post.caption)
                        .font(.system(size: 14, design: .rounded))
                        .foregroundStyle(.white.opacity(0.85))
                        .lineSpacing(2)
                        .padding(.top, 4)
                }

                // ── Like + share row ──
                HStack(spacing: 12) {
                    Button {
                        let g = UIImpactFeedbackGenerator(style: .light); g.impactOccurred()
                        onLike()
                    } label: {
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
                    Spacer()
                    ShareLink(
                        item: URL(string: post.photoUrl) ?? URL(string: "https://carsspotter.com")!,
                        subject: Text("\(post.year) \(post.make) \(post.model)")
                    ) {
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
                .padding(.top, 4)
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
