import SwiftUI

struct CompletedBadge: View {
    var body: some View {
        Label("Completed", systemImage: "checkmark.seal.fill")
            .font(.caption.weight(.bold))
            .foregroundStyle(AppTheme.indiaGreen)
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(AppTheme.indiaGreen.opacity(0.12), in: Capsule())
            .accessibilityLabel("Completed survey")
    }
}
