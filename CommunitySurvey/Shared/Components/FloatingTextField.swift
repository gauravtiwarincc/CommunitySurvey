import SwiftUI

struct FloatingTextField: View {
    let title: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var isSecure = false
    var axis: Axis = .horizontal

    @FocusState private var isFocused: Bool

    private var isFloating: Bool { isFocused || !text.isEmpty }

    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(uiColor: .secondarySystemGroupedBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(isFocused ? AppTheme.saffron : Color.secondary.opacity(0.16), lineWidth: 1.2)
                )
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(isFloating ? .caption.weight(.semibold) : .body)
                    .foregroundStyle(isFocused ? AppTheme.saffron : .secondary)
                field
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
        }
        .frame(minHeight: axis == .vertical ? 104 : 58)
        .animation(.easeInOut(duration: 0.16), value: isFocused)
        .accessibilityElement(children: .contain)
    }

    @ViewBuilder
    private var field: some View {
        if isSecure {
            SecureField("", text: $text)
                .keyboardType(keyboardType)
                .focused($isFocused)
                .privacySensitive()
        } else {
            TextField("", text: $text, axis: axis)
                .keyboardType(keyboardType)
                .focused($isFocused)
        }
    }
}
