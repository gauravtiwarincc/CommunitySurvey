import Foundation
import Observation

@MainActor
@Observable
final class AdminUsersViewModel {
    var users: [AdminUser] = []
    var searchText = ""
    var totalCount = 0
    var isLoading = false
    var errorMessage: String?

    private let adminService: AdminServiceProtocol
    private var page = 1

    init(adminService: AdminServiceProtocol) {
        self.adminService = adminService
    }

    func load(reset: Bool = true) async {
        guard !isLoading else { return }
        if reset { page = 1 }
        isLoading = true
        errorMessage = nil
        do {
            let response = try await adminService.fetchUsers(search: searchText, page: page)
            users = reset ? response.users : users + response.users
            totalCount = response.totalCount ?? users.count
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func refresh() async {
        await load(reset: true)
    }
}
