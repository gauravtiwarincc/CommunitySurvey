import SwiftUI

enum AppTheme {
    static let saffron = Color(red: 0.96, green: 0.42, blue: 0.12)
    static let deepSaffron = Color(red: 0.78, green: 0.26, blue: 0.05)
    static let indiaGreen = Color(red: 0.05, green: 0.52, blue: 0.30)
    static let mint = Color(red: 0.59, green: 0.89, blue: 0.72)
    static let ink = Color(red: 0.08, green: 0.09, blue: 0.12)
    static let surface = Color(uiColor: .secondarySystemGroupedBackground)
    static let background = Color(uiColor: .systemGroupedBackground)

    static var brandGradient: LinearGradient {
        LinearGradient(colors: [saffron, indiaGreen], startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    static var softGradient: LinearGradient {
        LinearGradient(colors: [saffron.opacity(0.20), indiaGreen.opacity(0.18), Color(.systemBackground)], startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    static var darkGradient: LinearGradient {
        LinearGradient(colors: [Color(red: 0.18, green: 0.11, blue: 0.06), Color(red: 0.02, green: 0.16, blue: 0.10)], startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}
