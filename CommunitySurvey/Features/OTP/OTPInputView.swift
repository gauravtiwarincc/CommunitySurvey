import SwiftUI

struct OTPInputView: View {
    @Binding var digits: [String]
    let onDigitChanged: (String, Int) -> Void
    let onAutoFill: (String) -> Void

    @FocusState private var isFocused: Bool

    private var otpText: Binding<String> {
        Binding(
            get: { digits.joined() },
            set: { value in
                let normalized = String(value.filter(\.isNumber).prefix(6))
                if normalized.count > 1 {
                    onAutoFill(normalized)
                } else {
                    updateDigits(with: normalized)
                }
            }
        )
    }

    var body: some View {
        ZStack {
            TextField("", text: otpText)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .focused($isFocused)
                .frame(width: 1, height: 1)
                .opacity(0.01)
                .accessibilityLabel("One time password")

            HStack(spacing: 10) {
                ForEach(0..<6, id: \.self) { index in
                    Text(character(at: index))
                        .font(.title3.monospacedDigit().weight(.semibold))
                        .frame(width: 46, height: 54)
                        .background(Color.secondary.opacity(0.10), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .stroke(borderColor(for: index), lineWidth: 1)
                        )
                        .contentShape(Rectangle())
                        .onTapGesture { isFocused = true }
                        .accessibilityLabel("OTP digit \(index + 1)")
                        .accessibilityValue(character(at: index).isEmpty ? "Empty" : "Entered")
                }
            }
        }
        .onAppear { isFocused = true }
    }

    private func updateDigits(with value: String) {
        let characters = Array(value).map(String.init)
        for index in 0..<6 {
            onDigitChanged(index < characters.count ? characters[index] : "", index)
        }
    }

    private func character(at index: Int) -> String {
        guard digits.indices.contains(index) else { return "" }
        return digits[index]
    }

    private func borderColor(for index: Int) -> Color {
        guard isFocused else { return Color.secondary.opacity(0.22) }
        let activeIndex = min(digits.joined().count, 5)
        return index == activeIndex ? Color.accentColor : Color.secondary.opacity(0.22)
    }
}
