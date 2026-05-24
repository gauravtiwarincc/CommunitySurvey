import Foundation

protocol AadhaarServiceProtocol: Sendable {
    func verify(aadhaarNumber: String) async throws -> AadhaarVerificationResult
}

struct AadhaarService: AadhaarServiceProtocol {
    private let apiClient: APIClientProtocol
    private let validationManager: ValidationManager

    init(apiClient: APIClientProtocol, validationManager: ValidationManager) {
        self.apiClient = apiClient
        self.validationManager = validationManager
    }

    func verify(aadhaarNumber: String) async throws -> AadhaarVerificationResult {
        let request = AadhaarVerificationRequest(aadhaarNumber: aadhaarNumber)
        return try await apiClient.send(APIEndpoint.verifyAadhaar(request), responseType: AadhaarVerificationResult.self)
    }
}

struct MockAadhaarService: AadhaarServiceProtocol {
    private let validationManager = ValidationManager()

    func verify(aadhaarNumber: String) async throws -> AadhaarVerificationResult {
        try await Task.sleep(for: .milliseconds(850))
        let masked = validationManager.maskedAadhaar(aadhaarNumber)
        return AadhaarVerificationResult(
            referenceID: "AAD-\(Int.random(in: 100000...999999))",
            maskedAadhaar: masked,
            status: .verified,
            message: "Aadhaar verification completed successfully.",
            verifiedAt: Date()
        )
    }
}
