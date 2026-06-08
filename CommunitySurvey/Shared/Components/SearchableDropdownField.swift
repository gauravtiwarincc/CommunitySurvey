import SwiftUI

struct SearchableDropdownField: View {
    let title: String
    @Binding var selection: String
    let options: [String]

    @State private var isPresented = false
    @State private var searchText = ""

    private var filteredOptions: [String] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return options }
        return options.filter { $0.localizedCaseInsensitiveContains(query) }
    }

    var body: some View {
        Button {
            searchText = ""
            isPresented = true
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Text(selection.isEmpty ? "Select" : selection)
                        .font(.body)
                        .foregroundStyle(selection.isEmpty ? .secondary : .primary)
                        .lineLimit(1)
                }
                Spacer()
                Image(systemName: "magnifyingglass.circle.fill")
                    .foregroundStyle(AppTheme.accent)
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
        .sheet(isPresented: $isPresented) {
            NavigationStack {
                List(filteredOptions, id: \.self) { option in
                    Button {
                        selection = option
                        isPresented = false
                    } label: {
                        HStack {
                            Text(option)
                                .foregroundStyle(.primary)
                            Spacer()
                            if selection == option {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(AppTheme.accent)
                            }
                        }
                    }
                }
                .searchable(text: $searchText, prompt: "Search \(title.lowercased())")
                .navigationTitle(title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { isPresented = false }
                    }
                }
            }
            .presentationDetents([.medium, .large])
        }
    }
}
