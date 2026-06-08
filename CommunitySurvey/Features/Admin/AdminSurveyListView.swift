import SwiftUI

struct AdminSurveyListView: View {
    let router: AppRouter

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                GradientBrandCard {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Survey Management")
                            .font(.title.bold())
                            .foregroundStyle(.white)
                        Text("Create, edit, archive, and monitor organization surveys.")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.82))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                GradientButton(title: "Create Survey", systemImage: "plus.circle.fill") {
                    router.navigate(to: .createSurvey)
                }
                EmptySurveyView(title: "Survey management ready", message: "Connect admin survey listing endpoints to enable edit and archive actions.")
            }
            .padding(20)
        }
        .background(AppTheme.softGradient.ignoresSafeArea())
        .navigationTitle("Admin Surveys")
    }
}
