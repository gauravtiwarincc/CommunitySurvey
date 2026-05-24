import SwiftUI

struct DropdownField: View {
    let title: String
    @Binding var selection: String
    let options: [String]

    var body: some View {
        Menu {
            ForEach(options, id: \.self) { option in
                Button(option) { selection = option }
            }
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Text(selection.isEmpty ? "Select" : selection)
                        .font(.body)
                        .foregroundStyle(selection.isEmpty ? .secondary : .primary)
                }
                Spacer()
                Image(systemName: "chevron.down.circle.fill")
                    .foregroundStyle(AppTheme.indiaGreen)
            }
            .padding(14)
            .frame(minHeight: 58)
            .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.secondary.opacity(0.16), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
        .accessibilityValue(selection.isEmpty ? "Not selected" : selection)
    }
}
