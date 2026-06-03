import SwiftUI

extension Font {
    /// 32pt bold — page titles
    static let spotterDisplay = Font.system(size: 32, weight: .bold, design: .rounded)
    /// 22pt semibold — section headers
    static let spotterTitle   = Font.system(size: 22, weight: .semibold, design: .rounded)
    /// 17pt medium — list rows, primary body
    static let spotterBody    = Font.system(size: 17, weight: .medium, design: .rounded)
    /// 12pt heavy with extra tracking — labels above values + uppercase pills
    static let spotterLabel   = Font.system(size: 12, weight: .heavy, design: .rounded)
    /// 11pt mono — code-y data display
    static let spotterMono    = Font.system(size: 11, weight: .medium, design: .monospaced)
}

extension Text {
    func spotterLabel() -> some View {
        self.font(.spotterLabel)
            .tracking(2)
            .foregroundStyle(Color.spotterMute)
            .textCase(.uppercase)
    }
}
