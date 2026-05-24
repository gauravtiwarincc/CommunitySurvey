import Foundation
import Observation

@MainActor
@Observable
final class WalletViewModel {
    var walletBalance = 0
    var transactions: [Transaction] = []
    var isLoading = false
    var errorMessage: String?

    private let walletService: WalletServiceProtocol

    init(walletService: WalletServiceProtocol) {
        self.walletService = walletService
    }

    func load() async {
        isLoading = true
        do {
            let response = try await walletService.getWallet()
            walletBalance = response.walletBalance
            transactions = response.transactions
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
