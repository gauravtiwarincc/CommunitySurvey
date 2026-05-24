import SwiftUI

struct AvailableSurveyCard: View {
    let survey: Survey
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            PremiumCard(padding: 16) {
                HStack(alignment: .center, spacing: 14) {
                    VStack(alignment: .leading, spacing: 9) {
                        RewardBadge(points: survey.rewardPoints)
                        Text(survey.title)
                            .font(.headline)
                            .foregroundStyle(.primary)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                        if let description = survey.description, !description.isEmpty {
                            Text(description)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)
                        }
                    }
                    Spacer(minLength: 8)
                    VStack(spacing: 8) {
                        Text("Start")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(AppTheme.brandGradient, in: Capsule())
                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(AppTheme.indiaGreen)
                    }
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Start survey, \(survey.title), reward \(survey.rewardPoints) points")
    }
}
