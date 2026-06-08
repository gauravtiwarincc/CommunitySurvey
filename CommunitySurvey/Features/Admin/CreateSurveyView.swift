import SwiftUI

struct CreateSurveyView: View {
    @State private var viewModel: CreateSurveyViewModel
    @Environment(\.dismiss) private var dismiss

    init(viewModel: CreateSurveyViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                PremiumCard(padding: 16) {
                    VStack(spacing: 12) {
                        FloatingTextField(title: "Survey Title", text: $viewModel.title)
                        FloatingTextField(title: "Description", text: $viewModel.description)
                        FloatingTextField(title: "Reward Points", text: rewardBinding, keyboardType: .numberPad)
                    }
                }
                questionsSection
                if let errorMessage = viewModel.errorMessage { ErrorBanner(message: errorMessage) }
                if let successMessage = viewModel.successMessage { successBanner(successMessage) }
                GradientButton(title: "Create Survey", systemImage: "checkmark.circle.fill", isEnabled: viewModel.canSubmit) {
                    Task { await viewModel.submit() }
                }
            }
            .padding(20)
        }
        .background(AppTheme.softGradient.ignoresSafeArea())
        .navigationTitle("Create Survey")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done") { dismiss() }
            }
        }
        .loadingOverlay(viewModel.isLoading, message: "Creating survey")
    }

    private var questionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Questions")
                    .font(.title3.bold())
                Spacer()
                Button { viewModel.addQuestion() } label: {
                    Label("Add", systemImage: "plus.circle.fill")
                }
            }
            ForEach($viewModel.questions) { $question in
                questionCard($question)
            }
        }
    }

    private func questionCard(_ question: Binding<CreateSurveyQuestion>) -> some View {
        PremiumCard(padding: 16) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Single Choice")
                        .font(.caption.bold())
                        .foregroundStyle(AppTheme.indiaGreen)
                    Spacer()
                    Button(role: .destructive) {
                        viewModel.removeQuestion(id: question.wrappedValue.id)
                    } label: {
                        Image(systemName: "trash")
                    }
                }
                FloatingTextField(title: "Question", text: question.question)
                ForEach(question.options) { $option in
                    HStack(spacing: 10) {
                        FloatingTextField(title: "Option", text: $option.title)
                        Button(role: .destructive) {
                            viewModel.removeOption(option.id, from: question.wrappedValue.id)
                        } label: {
                            Image(systemName: "minus.circle.fill")
                        }
                        .disabled(question.wrappedValue.options.count <= 2)
                    }
                }
                Button { viewModel.addOption(to: question.wrappedValue.id) } label: {
                    Label("Add Option", systemImage: "plus.circle")
                        .font(.subheadline.weight(.semibold))
                }
            }
        }
    }

    private func successBanner(_ message: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(AppTheme.indiaGreen)
            Text(message)
                .font(.subheadline)
            Spacer()
        }
        .padding(12)
        .background(AppTheme.indiaGreen.opacity(0.12), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private var rewardBinding: Binding<String> {
        Binding(get: { viewModel.rewardPoints }, set: { viewModel.rewardPoints = String($0.filter(\.isNumber).prefix(5)) })
    }
}
