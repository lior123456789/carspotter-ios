import SwiftUI

struct PostCardView: View {
    let post: FeedPost
    let onLike: () -> Void
    let onDelete: (() -> Void)?
    /// Report this post with a chosen reason (UGC compliance).
    var onReport: ((ModerationService.ReportReason) -> Void)? = nil
    /// Block this post's author (UGC compliance).
    var onBlock: (() -> Void)? = nil

    @State private var showReportDialog = false
    @State private var showBlockConfirm = false

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            avatar

            VStack(alignment: .leading, spacing: 7) {
                // ── username · time + menu ──
                HStack(spacing: 5) {
                    Text(post.displayName)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    Text("· \(post.timeAgo)")
                        .font(.system(size: 13, design: .rounded))
                        .foregroundStyle(Color.spotterMute)
                    Spacer(minLength: 0)
                    menu
                }

                // ── car identity (the "post text") ──
                HStack(alignment: .firstTextBaseline, spacing: 5) {
                    Text(post.year)
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.55))
                    Text("\(post.make) \(post.model)")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .lineLimit(2)
                        .minimumScaleFactor(0.85)
                }

                if !post.caption.isEmpty {
                    Text(post.caption)
                        .font(.system(size: 15, design: .rounded))
                        .foregroundStyle(.white.opacity(0.9))
                        .lineSpacing(2)
                        .fixedSize(horizontal: false, vertical: true)
                }

                if let loc = post.location {
                    HStack(spacing: 3) {
                        Image(systemName: "mappin.circle.fill").font(.system(size: 11))
                        Text(loc).font(.system(size: 13, design: .rounded)).lineLimit(1)
                    }
                    .foregroundStyle(Color.spotterMute)
                }

                // ── media card ──
                photo
                    .frame(maxWidth: .infinity)
                    .frame(height: 300)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Color.spotterLine))
                    .overlay(alignment: .topLeading) {
                        HStack(spacing: 6) {
                            BadgePill(label: post.category, color: .spotterCyan)
                            if post.rarity >= 8 {
                                BadgePill(label: "Rare \(post.rarity)/10", icon: "trophy.fill", color: .yellow)
                            }
                        }
                        .padding(10)
                    }
                    .overlay(alignment: .bottomTrailing) {
                        Text(post.valueRange)
                            .font(.system(size: 13, weight: .heavy, design: .rounded))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 10).padding(.vertical, 6)
                            .background(.ultraThinMaterial, in: Capsule())
                            .padding(10)
                    }
                    .padding(.top, 2)

                // ── action row (Threads-style: small left-aligned icons) ──
                HStack(spacing: 22) {
                    Button {
                        let g = UIImpactFeedbackGenerator(style: .light); g.impactOccurred()
                        onLike()
                    } label: {
                        actionIcon(post.likedByMe ? "heart.fill" : "heart",
                                   count: post.likeCount,
                                   tint: post.likedByMe ? .red : .white)
                    }
                    .buttonStyle(.plain)

                    ShareLink(
                        item: URL(string: post.photoUrl) ?? URL(string: "https://carsspotter.com")!,
                        subject: Text("\(post.year) \(post.make) \(post.model)")
                    ) {
                        actionIcon("paperplane", count: nil, tint: .white)
                    }
                    Spacer(minLength: 0)
                }
                .padding(.top, 3)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .overlay(alignment: .bottom) {
            Rectangle().fill(Color.spotterLine).frame(height: 0.5)
        }
        .confirmationDialog("Report this post?",
                            isPresented: $showReportDialog,
                            titleVisibility: .visible) {
            ForEach(ModerationService.ReportReason.allCases) { reason in
                Button(reason.rawValue) { onReport?(reason) }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Our team reviews reports within 24 hours and removes content that violates our guidelines. You won't see this post again.")
        }
        .confirmationDialog("Block \(post.displayName)?",
                            isPresented: $showBlockConfirm,
                            titleVisibility: .visible) {
            Button("Block", role: .destructive) { onBlock?() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("You won't see posts from \(post.displayName) anymore.")
        }
    }

    // MARK: - Pieces

    private func actionIcon(_ system: String, count: Int?, tint: Color) -> some View {
        HStack(spacing: 6) {
            Image(systemName: system)
                .font(.system(size: 18, weight: .regular))
                .foregroundStyle(tint)
            if let count, count > 0 {
                Text("\(count)")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .contentTransition(.numericText())
            }
        }
    }

    @ViewBuilder private var menu: some View {
        Menu {
            if let onDelete {
                Button(role: .destructive) { onDelete() } label: {
                    Label("Delete post", systemImage: "trash")
                }
            }
            if onReport != nil {
                Button { showReportDialog = true } label: {
                    Label("Report post", systemImage: "flag")
                }
            }
            if onBlock != nil {
                Button(role: .destructive) { showBlockConfirm = true } label: {
                    Label("Block \(post.displayName)", systemImage: "hand.raised")
                }
            }
        } label: {
            Image(systemName: "ellipsis")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(Color.spotterMute)
                .padding(.leading, 8)
        }
    }

    @ViewBuilder private var photo: some View {
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
    }

    @ViewBuilder private var avatar: some View {
        if let urlStr = post.avatarUrl, !urlStr.isEmpty, let url = URL(string: urlStr) {
            AsyncImage(url: url) { img in
                img.resizable().scaledToFill()
            } placeholder: {
                LinearGradient.spotterBrand
            }
            .frame(width: 40, height: 40)
            .clipShape(Circle())
        } else {
            ZStack {
                LinearGradient.spotterBrand
                Text(post.displayName.prefix(1).uppercased())
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }
            .frame(width: 40, height: 40)
            .clipShape(Circle())
        }
    }
}
