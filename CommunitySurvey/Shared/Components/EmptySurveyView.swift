import SwiftUI

struct EmptySurveyView: View {
    var body: some View {
        PremiumCard {
            VStack(spacing: 12) {
                Image(systemName: "doc.text.magnifyingglass")
                    .font(.largeTitle)
                    .foregroundStyle(AppTheme.saffron)
                Text("No surveys available")
                    .font(.headline)
                Text("New verified opinion surveys will appear here when available.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
        }
    }
}
