import SwiftUI

struct StatRow: View {
    let label: String
    let value: String
    var accent: Bool = false
    var bar: Double? = nil   // 0-1 fills a thin progress line

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label.uppercased())
                .font(.system(size: 10, weight: .heavy, design: .rounded))
                .tracking(2)
                .foregroundStyle(Color.spotterMute)

            Text(value)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundStyle(accent ? Color.spotterCyan : .white)

            if let bar {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(.white.opacity(0.08))
                            .frame(height: 4)
                        RoundedRectangle(cornerRadius: 2)
                            .fill(LinearGradient.spotterBrand)
                            .frame(width: geo.size.width * max(0, min(1, bar)), height: 4)
                    }
                }
                .frame(height: 4)
                .padding(.top, 2)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 14)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(accent ? Color.spotterCyan.opacity(0.07) : Color.spotterPanel)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(accent ? Color.spotterCyan.opacity(0.3) : Color.spotterLine, lineWidth: 1)
        )
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
