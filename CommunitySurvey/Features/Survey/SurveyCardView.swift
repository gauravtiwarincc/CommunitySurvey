import SwiftUI

struct SurveyCardView: View {
    let survey: Survey

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    Text("+\(survey.rewardPoints) pts")
                        .font(.caption.bold())
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(AppTheme.saffron.opacity(0.14), in: Capsule())
                        .foregroundStyle(AppTheme.deepSaffron)
                    if survey.isCompleted {
                        Label("Completed", systemImage: "checkmark.seal.fill")
                            .font(.caption.bold())
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(AppTheme.indiaGreen.opacity(0.14), in: Capsule())
                            .foregroundStyle(AppTheme.indiaGreen)
                    }
                }
                Text(survey.title)
                    .font(.headline)
                    .foregroundStyle(survey.isCompleted ? .secondary : .primary)
                    .fixedSize(horizontal: false, vertical: true)
                if let description = survey.description, !description.isEmpty {
                    Text(description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(3)
                }
            }
            Spacer(minLength: 12)
            Image(systemName: survey.isCompleted ? "checkmark.circle.fill" : "chevron.right.circle.fill")
                .font(.title2)
                .foregroundStyle(survey.isCompleted ? AppTheme.indiaGreen : AppTheme.saffron)
                .padding(.top, 4)
        }
        .padding(16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(survey.isCompleted ? AppTheme.indiaGreen.opacity(0.22) : Color.white.opacity(0.20), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(survey.isCompleted ? 0.04 : 0.10), radius: 14, x: 0, y: 8)
        .opacity(survey.isCompleted ? 0.72 : 1)
        .accessibilityElement(children: .combine)
    }
}
