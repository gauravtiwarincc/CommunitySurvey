import SwiftUI

struct SurveyDetailView: View {
    @State private var viewModel: SurveyDetailViewModel
    @Environment(\.dismiss) private var dismiss

    init(viewModel: SurveyDetailViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(spacing: 18) {
                    content
                }
                .padding(20)
                .padding(.bottom, 92)
            }
            .background(AppTheme.softGradient.ignoresSafeArea())
            submitBar
        }
        .navigationTitle("Survey Details")
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.load() }
        .onChange(of: viewModel.completionState) { _, state in
            guard case .completed = state else { return }
            Task {
                try? await Task.sleep(for: .milliseconds(850))
                dismiss()
            }
        }
        .loadingOverlay(viewModel.isLoading || viewModel.completionState == .submitting, message: viewModel.completionState == .submitting ? "Submitting survey" : "Loading survey")
    }

    @ViewBuilder
    private var content: some View {
        if let survey = viewModel.survey {
            surveyHeader(survey)
            progressCard
            ForEach(survey.questions) { question in
                questionCard(question)
            }
            if case .completed(let message) = viewModel.completionState {
                successCard(message)
            }
            if let errorMessage = viewModel.errorMessage {
                ErrorBanner(message: errorMessage)
            }
        } else if case .completed(let message) = viewModel.completionState {
            successCard(message)
        } else if viewModel.isLoading {
            LoadingView()
        } else if let errorMessage = viewModel.errorMessage {
            ErrorStateView(message: errorMessage) {
                Task { await viewModel.load() }
            }
        }
    }

    private func surveyHeader(_ survey: SurveyDetail) -> some View {
        GradientBrandCard {
            VStack(alignment: .leading, spacing: 10) {
                Text(survey.title)
                    .font(.title.bold())
                    .foregroundStyle(.white)
                    .fixedSize(horizontal: false, vertical: true)
                Text(survey.description ?? "Complete all questions to earn rewards.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.82))
                RewardBadge(points: survey.rewardPoints)
                    .background(.white.opacity(0.12), in: Capsule())
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var progressCard: some View {
        PremiumCard(padding: 14) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Progress")
                        .font(.subheadline.weight(.semibold))
                    Spacer()
                    Text("\(viewModel.answeredCount)/\(viewModel.totalQuestions)")
                        .font(.subheadline.monospacedDigit().bold())
                        .foregroundStyle(AppTheme.indiaGreen)
                }
                ProgressView(value: Double(viewModel.answeredCount), total: Double(max(viewModel.totalQuestions, 1)))
                    .tint(AppTheme.indiaGreen)
            }
        }
    }

    private func questionCard(_ question: SurveyQuestion) -> some View {
        PremiumCard {
            VStack(alignment: .leading, spacing: 14) {
                Text(question.question)
                    .font(.headline)
                    .fixedSize(horizontal: false, vertical: true)
                ForEach(question.options) { option in
                    RadioOptionRow(
                        title: option.title,
                        isSelected: viewModel.selectedAnswers[question.id] == option.id
                    ) {
                        viewModel.select(option: option, for: question)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func successCard(_ message: String) -> some View {
        PremiumCard {
            VStack(spacing: 12) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.largeTitle)
                    .foregroundStyle(AppTheme.indiaGreen)
                Text(message)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                Text("Returning to dashboard")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
        }
    }

    @ViewBuilder
    private var submitBar: some View {
        if viewModel.survey != nil, viewModel.completionState == .editing {
            VStack(spacing: 0) {
                Divider()
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Reward")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("+\(viewModel.survey?.rewardPoints ?? 0) pts")
                            .font(.headline.monospacedDigit())
                    }
                    Spacer()
                    PrimaryButton(title: "Submit Survey", systemImage: "paperplane.fill", isEnabled: viewModel.canSubmit) {
                        Task { await viewModel.submit() }
                    }
                    .frame(maxWidth: 220)
                }
                .padding(16)
                .background(.regularMaterial)
            }
        }
    }
}
