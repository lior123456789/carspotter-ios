import SwiftUI

struct StatRow: View {
    let label: String
    let value: String
    var accent: Bool = false
    var bar: Double? = nil   // 0-1 fills a thin progress line

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label.uppercased())
                .font(.system(size: 10, weight: .heavy, design: .rounded))
                .tracking(1.8)
                .foregroundStyle(Color.spotterMute)

            Group {
                if accent {
                    Text(value)
                        .foregroundStyle(LinearGradient.spotterBrand)
                } else {
                    Text(value)
                        .foregroundStyle(.white)
                }
            }
            .font(.system(size: 19, weight: .bold, design: .rounded))
            .minimumScaleFactor(0.7)
            .lineLimit(2)

            if let bar {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(.white.opacity(0.08)).frame(height: 5)
                        Capsule()
                            .fill(LinearGradient.spotterBrand)
                            .frame(width: geo.size.width * max(0, min(1, bar)), height: 5)
                            .shadow(color: Color.spotterCyan.opacity(0.5), radius: 4)
                    }
                }
                .frame(height: 5)
                .padding(.top, 3)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: accent
                            ? [Color.spotterCyan.opacity(0.12), Color.spotterViolet.opacity(0.06)]
                            : [Color.white.opacity(0.05), Color.white.opacity(0.02)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(accent ? Color.spotterCyan.opacity(0.35) : Color.spotterLine, lineWidth: 1)
        )
        .shadow(color: accent ? Color.spotterCyan.opacity(0.15) : .clear, radius: 10, y: 4)
    }
}

struct BadgePill: View {
    let label: String
    var icon: String? = nil
    var color: Color = .spotterCyan

    var body: some View {
        HStack(spacing: 6) {
            if let icon { Image(systemName: icon).font(.system(size: 10, weight: .heavy)) }
            Text(label.uppercased())
                .font(.system(size: 10, weight: .heavy, design: .rounded))
                .tracking(1.5)
        }
        .foregroundStyle(color)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(color.opacity(0.12))
        .overlay(Capsule().stroke(color.opacity(0.35), lineWidth: 1))
        .clipShape(Capsule())
    }
}
