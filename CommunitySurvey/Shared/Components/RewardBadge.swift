import SwiftUI

struct RewardBadge: View {
    let points: Int
    var label = "Reward"

    var body: some View {
        Label("+\(points) pts", systemImage: "gift.fill")
            .font(.caption.weight(.bold).monospacedDigit())
            .foregroundStyle(AppTheme.deepSaffron)
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(AppTheme.saffron.opacity(0.14), in: Capsule())
            .accessibilityLabel("\(label), \(points) points")
    }
}
