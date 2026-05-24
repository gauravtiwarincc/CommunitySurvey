import SwiftUI

struct CountryCodePicker: View {
    @Binding var selection: String

    private let countries = [
        ("India", "+91"),
        ("United States", "+1"),
        ("United Kingdom", "+44"),
        ("Singapore", "+65")
    ]

    var body: some View {
        Menu {
            ForEach(countries, id: \.1) { country in
                Button("\(country.0) \(country.1)") {
                    selection = country.1
                }
            }
        } label: {
            HStack(spacing: 6) {
                Text(selection)
                    .font(.body.monospacedDigit())
                Image(systemName: "chevron.down")
                    .font(.caption.weight(.semibold))
            }
            .frame(width: 84, height: 48)
            .background(Color.secondary.opacity(0.12), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
        .accessibilityLabel("Country code")
        .accessibilityValue(selection)
    }
}
