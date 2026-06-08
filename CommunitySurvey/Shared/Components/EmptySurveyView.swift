import SwiftUI

struct EmptySurveyView: View {
    var title = "No surveys available"
    var message = "New verified opinion surveys will appear here when available."
    var systemImage = "doc.text.magnifyingglass"

    var body: some View {
        PremiumCard {
            VStack(spacing: 12) {
                Image(systemName: systemImage)
                    .font(.largeTitle)
                    .foregroundStyle(AppTheme.saffron)
                Text(title)
                    .font(.headline)
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
        }
    }
}
