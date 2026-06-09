import SwiftUI

struct MainTabView: View {
    let container: DependencyContainer

    var body: some View {
        if container.roleManager.canAccessAdmin {
            AdminTabView(container: container)
        } else {
            UserTabView(container: container)
        }
    }
}

struct UserTabView: View {
    let container: DependencyContainer

    var body: some View {
        TabView {
            DashboardView(viewModel: DashboardViewModel(surveyStore: container.surveyStateStore), router: container.router)
                .tabItem { Label("Dashboard", systemImage: "square.grid.2x2.fill") }

            SurveyListView(viewModel: SurveyListViewModel(surveyStore: container.surveyStateStore), router: container.router)
                .tabItem { Label("Surveys", systemImage: "doc.text.fill") }

            ProfileView(viewModel: ProfileViewModel(profileService: container.profileService, authService: container.authService, surveyStore: container.surveyStateStore, sessionManager: container.sessionManager, themeManager: container.themeManager, router: container.router))
                .tabItem { Label("Profile", systemImage: "person.crop.circle.fill") }
        }
        .tint(AppTheme.accent)
    }
}

struct AdminTabView: View {
    let container: DependencyContainer

    var body: some View {
        TabView {
            DashboardView(viewModel: DashboardViewModel(surveyStore: container.surveyStateStore), router: container.router)
                .tabItem { Label("Dashboard", systemImage: "square.grid.2x2.fill") }

            SurveyListView(viewModel: SurveyListViewModel(surveyStore: container.surveyStateStore), router: container.router)
                .tabItem { Label("Surveys", systemImage: "doc.text.fill") }

            AdminDashboardView(viewModel: AdminDashboardViewModel(adminService: container.adminService), roleManager: container.roleManager, sessionManager: container.sessionManager, router: container.router)
                .tabItem { Label("Admin", systemImage: "person.3.sequence.fill") }

            ProfileView(viewModel: ProfileViewModel(profileService: container.profileService, authService: container.authService, surveyStore: container.surveyStateStore, sessionManager: container.sessionManager, themeManager: container.themeManager, router: container.router))
                .tabItem { Label("Profile", systemImage: "person.crop.circle.fill") }
        }
        .tint(AppTheme.accent)
    }
}
