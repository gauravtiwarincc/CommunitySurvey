import Foundation
import Observation

@MainActor
@Observable
final class RewardsViewModel {
    var transactions: [RewardTransaction] = []
    var isLoading = false
    var errorMessage: String?

    private let repository: SurveyRepositoryProtocol

    init(repository: SurveyRepositoryProtocol) {
        self.repository = repository
    }

    var walletBalance: Decimal {
        transactions.reduce(Decimal(420)) { $0 + $1.amount }
    }

    func load() async {
        isLoading = true
        do {
            transactions = try await repository.fetchRewards()
        } catch {
            errorMessage = (error as? AppError ?? .unknown(error.localizedDescription)).localizedDescription
        }
        isLoading = false
    }
}
