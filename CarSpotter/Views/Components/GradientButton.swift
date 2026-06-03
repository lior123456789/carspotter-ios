import SwiftUI

struct GradientButton: View {
    let title: String
    var icon: String? = nil
    var loading: Bool = false
    var style: Style = .primary
    let action: () -> Void

    enum Style {
        case primary, secondary, ghost
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if loading {
                    ProgressView()
                        .tint(.white)
                        .frame(width: 16, height: 16)
                } else if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                }
                Text(title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
            }
            .foregroundStyle(style == .secondary ? .black : .white)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(border)
            .shadow(color: shadowColor, radius: 14, x: 0, y: 6)
        }
        .disabled(loading)
    }

    @ViewBuilder private var background: some View {
        switch style {
        case .primary:
            LinearGradient.spotterBrand
        case .secondary:
            Color.white
        case .ghost:
            Color.spotterPanel
        }
    }

    @ViewBuilder private var border: some View {
        switch style {
        case .ghost:
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.spotterLine, lineWidth: 1)
        default:
            EmptyView()
        }
    }

    private var shadowColor: Color {
        switch style {
        case .primary: return .spotterCyan.opacity(0.35)
        default:       return .black.opacity(0.15)
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        GradientButton(title: "Continue", icon: "arrow.right", action: {})
        GradientButton(title: "Sign in", icon: "applelogo", style: .secondary, action: {})
        GradientButton(title: "Use guest mode", style: .ghost, action: {})
        GradientButton(title: "Submitting…", loading: true, action: {})
    }
    .padding(32)
    .background(Color.spotterInk)
}
