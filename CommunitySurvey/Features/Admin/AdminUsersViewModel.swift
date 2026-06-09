import Foundation
import Observation

@MainActor
@Observable
final class AdminUsersViewModel {
    var users: [AdminUserItem] = []
    var searchText = ""
    var totalCount = 0
    var totalPages = 1
    var isLoading = false
    var errorMessage: String?

    private let adminService: AdminServiceProtocol
    private var page = 1

    init(adminService: AdminServiceProtocol) {
        self.adminService = adminService
    }

    func load(reset: Bool = true) async {
        if reset {
            page = 1
            users = []
            totalPages = 1
        }
        
        guard !isLoading && (page <= totalPages || reset) else { return }
        
        isLoading = true
        errorMessage = nil
        do {
            let response = try await adminService.fetchUsers(search: searchText, page: page)
            users = reset ? response.users : users + response.users
            totalCount = response.pagination.totalUsers
            totalPages = response.pagination.totalPages
            page += 1
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func refresh() async {
        await load(reset: true)
    }
}
