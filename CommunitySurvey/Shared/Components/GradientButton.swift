import SwiftUI

struct GradientButton: View {
    let title: String
    var systemImage: String? = nil
    var isEnabled = true
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                if let systemImage {
                    Image(systemName: systemImage)
                }
                Text(title)
                    .font(.headline)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .foregroundStyle(.white)
            .background(isEnabled ? AppTheme.brandGradient : LinearGradient(colors: [.secondary.opacity(0.25)], startPoint: .top, endPoint: .bottom), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: isEnabled ? AppTheme.indiaGreen.opacity(0.20) : .clear, radius: 14, x: 0, y: 8)
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .scaleEffect(isEnabled ? 1 : 0.99)
        .animation(.spring(response: 0.26, dampingFraction: 0.82), value: isEnabled)
        .accessibilityAddTraits(.isButton)
    }
}
