import SwiftUI

struct AdPlaceholderView: View {
    let title: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "rectangle.and.text.magnifyingglass")
                .foregroundStyle(AppTheme.saffron)
            Text(title)
                .font(.footnote.weight(.medium))
                .foregroundStyle(.secondary)
            Spacer()
            Text("Sponsored")
                .font(.caption2.weight(.bold))
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(AppTheme.saffron.opacity(0.14), in: Capsule())
        }
        .padding(14)
        .background(Color(uiColor: .tertiarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .accessibilityElement(children: .combine)
    }
}
