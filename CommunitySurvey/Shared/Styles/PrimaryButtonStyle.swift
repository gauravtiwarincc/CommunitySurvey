import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    var isEnabled = true

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(isEnabled ? Color.accentColor.opacity(configuration.isPressed ? 0.75 : 1) : Color.secondary.opacity(0.25))
            .foregroundStyle(isEnabled ? Color.white : Color.secondary)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .animation(.easeInOut(duration: 0.16), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == PrimaryButtonStyle {
    static func primary(isEnabled: Bool = true) -> PrimaryButtonStyle {
        PrimaryButtonStyle(isEnabled: isEnabled)
    }
}
