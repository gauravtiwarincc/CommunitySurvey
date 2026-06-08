import SwiftUI

enum AppTheme {
    private static var theme: ThemeManager { ThemeManager.shared }

    static var saffron: Color { theme.primary }
    static var deepSaffron: Color { theme.primary }
    static var indiaGreen: Color { theme.secondary }
    static var mint: Color { theme.secondary.opacity(0.55) }
    static var ink: Color { Color.primary }
    static var surface: Color { Color(uiColor: .secondarySystemGroupedBackground) }
    static var background: Color { Color(uiColor: .systemGroupedBackground) }
    static var accent: Color { theme.accent }

    static var brandGradient: LinearGradient { theme.brandGradient }
    static var softGradient: LinearGradient { theme.softGradient }

    static var darkGradient: LinearGradient {
        LinearGradient(colors: [theme.primary.opacity(0.34), theme.secondary.opacity(0.34)], startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}
