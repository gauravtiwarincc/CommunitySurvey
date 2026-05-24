import SwiftUI

struct CompletedSurveyCard: View {
    let survey: Survey

    var body: some View {
        PremiumCard(padding: 16) {
            HStack(alignment: .center, spacing: 14) {
                VStack(alignment: .leading, spacing: 9) {
                    CompletedBadge()
                    Text(survey.title)
                        .font(.headline)
                        .foregroundStyle(.primary.opacity(0.72))
                        .fixedSize(horizontal: false, vertical: true)
                    if let description = survey.description, !description.isEmpty {
                        Text(description)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                }
                Spacer(minLength: 8)
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Earned")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("+\(survey.rewardPoints)")
                        .font(.headline.weight(.bold).monospacedDigit())
                        .foregroundStyle(AppTheme.indiaGreen)
                }
            }
        }
        .opacity(0.78)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Completed survey, \(survey.title), earned \(survey.rewardPoints) points")
    }
}
