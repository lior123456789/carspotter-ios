import SwiftUI

extension Color {
    /// Matches `spotter-cyan` from the web (#22D3EE)
    static let spotterCyan   = Color(hex: 0x22D3EE)
    /// Matches `spotter-violet` from the web (#A855F7)
    static let spotterViolet = Color(hex: 0xA855F7)
    /// Matches `spotter-glow` from the web (#06B6D4)
    static let spotterGlow   = Color(hex: 0x06B6D4)
    /// Matches `spotter-ink` from the web (#05050B)
    static let spotterInk    = Color(hex: 0x05050B)
    /// Matches `spotter-panel` from the web (#0E0E18)
    static let spotterPanel  = Color(hex: 0x0E0E18)
    /// Matches `spotter-line` from the web (#1A1A28)
    static let spotterLine   = Color(hex: 0x1A1A28)
    /// Matches `spotter-mute` from the web (#8A8A95)
    static let spotterMute   = Color(hex: 0x8A8A95)

    init(hex: UInt32, opacity: Double = 1.0) {
        let r = Double((hex >> 16) & 0xFF) / 255.0
        let g = Double((hex >> 8) & 0xFF) / 255.0
        let b = Double(hex & 0xFF) / 255.0
        self.init(.sRGB, red: r, green: g, blue: b, opacity: opacity)
    }
}

extension LinearGradient {
    /// The signature cyan→violet brand gradient used on every CTA + accent.
    static let spotterBrand = LinearGradient(
        colors: [.spotterCyan, .spotterViolet],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Subtle background tint, sits under the hero/scan loader.
    static let spotterBackdrop = LinearGradient(
        colors: [Color(hex: 0x05050B), Color(hex: 0x0E0E18)],
        startPoint: .top,
        endPoint: .bottom
    )
}
