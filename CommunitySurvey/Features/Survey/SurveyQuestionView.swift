import SwiftUI

struct SurveyQuestionView: View {
    @State private var viewModel: SurveyViewModel

    init(viewModel: SurveyViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                AdPlaceholderView(title: "Responsible civic partner message")
                progressHeader
                rewardCard
                questionCard
                AdPlaceholderView(title: "Public awareness slot")
            }
            .padding(20)
        }
        .background(AppTheme.softGradient.ignoresSafeArea())
        .navigationTitle("Survey")
        .loadingOverlay(viewModel.isSubmitting, message: "Crediting reward")
    }

    private var progressHeader: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Question \(viewModel.currentIndex + 1) of \(viewModel.survey.questions.count)")
                    .font(.headline)
                Spacer()
                Label("\(viewModel.secondsRemaining)s", systemImage: "timer")
                    .font(.subheadline.monospacedDigit())
                    .foregroundStyle(AppTheme.saffron)
            }
            ProgressView(value: viewModel.progress)
                .tint(AppTheme.indiaGreen)
        }
        .accessibilityElement(children: .combine)
    }

    private var rewardCard: some View {
        GradientBrandCard {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Reward for completion")
                        .font(.caption.bold())
                        .foregroundStyle(.white.opacity(0.78))
                    Text("₹\(viewModel.survey.reward.description)")
                        .font(.largeTitle.bold())
                        .foregroundStyle(.white)
                }
                Spacer()
                Image(systemName: "gift.fill")
                    .font(.system(size: 42))
                    .foregroundStyle(.white.opacity(0.92))
            }
        }
    }

    private var questionCard: some View {
        PremiumCard {
            VStack(alignment: .leading, spacing: 16) {
                Text(viewModel.question.text)
                    .font(.title3.bold())
                    .fixedSize(horizontal: false, vertical: true)
                ForEach(viewModel.question.options) { option in
                    optionRow(option)
                }
                if let errorMessage = viewModel.errorMessage {
                    ErrorBanner(message: errorMessage)
                }
                HStack(spacing: 12) {
                    Button("Skip") { viewModel.skip() }
                        .buttonStyle(.bordered)
                    GradientButton(title: viewModel.isLastQuestion ? "Submit" : "Next", systemImage: "arrow.right", isEnabled: viewModel.selectedOptionID != nil) {
                        Task { await viewModel.next() }
                    }
                }
            }
        }
    }

    private func optionRow(_ option: SurveyOption) -> some View {
        let isSelected = viewModel.selectedOptionID == option.id
        return HStack(spacing: 12) {
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(isSelected ? AppTheme.indiaGreen : .secondary)
            Text(option.title)
                .font(.body.weight(isSelected ? .semibold : .regular))
            Spacer()
        }
        .padding(14)
        .background(isSelected ? AppTheme.indiaGreen.opacity(0.14) : Color(uiColor: .tertiarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(isSelected ? AppTheme.indiaGreen : Color.clear, lineWidth: 1.4)
        )
        .scaleEffect(isSelected ? 1.02 : 1)
        .animation(.spring(response: 0.25, dampingFraction: 0.8), value: isSelected)
        .onTapGesture { viewModel.select(option) }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }
}
