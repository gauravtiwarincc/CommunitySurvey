import Foundation

struct ValidationManager: Sendable {
    func validateMobile(_ value: String) -> Result<String, AppError> {
        let digits = value.filter(\.isNumber)
        guard digits.count == 10 else {
            return .failure(.validation("Enter a valid 10-digit mobile number."))
        }
        guard ["6", "7", "8", "9"].contains(String(digits.prefix(1))) else {
            return .failure(.validation("Indian mobile numbers should start with 6, 7, 8, or 9."))
        }
        return .success(digits)
    }

    func validateOTP(_ value: String) -> Result<String, AppError> {
        let digits = value.filter(\.isNumber)
        guard digits.count == 6 else {
            return .failure(.validation("Enter the 6-digit OTP."))
        }
        return .success(digits)
    }

    func validateAadhaar(_ value: String) -> Result<String, AppError> {
        let digits = value.filter(\.isNumber)
        guard digits.count == 12 else {
            return .failure(.validation("Enter a valid 12-digit Aadhaar number."))
        }
        guard verhoeffIsValid(digits) else {
            return .failure(.validation("Aadhaar number failed checksum validation."))
        }
        return .success(digits)
    }

    func maskedAadhaar(_ value: String) -> String {
        let digits = value.filter(\.isNumber)
        guard digits.count >= 4 else { return digits }
        return "XXXX XXXX " + digits.suffix(4)
    }

    private func verhoeffIsValid(_ number: String) -> Bool {
        let multiplication = [[0,1,2,3,4,5,6,7,8,9],[1,2,3,4,0,6,7,8,9,5],[2,3,4,0,1,7,8,9,5,6],[3,4,0,1,2,8,9,5,6,7],[4,0,1,2,3,9,5,6,7,8],[5,9,8,7,6,0,4,3,2,1],[6,5,9,8,7,1,0,4,3,2],[7,6,5,9,8,2,1,0,4,3],[8,7,6,5,9,3,2,1,0,4],[9,8,7,6,5,4,3,2,1,0]]
        let permutation = [[0,1,2,3,4,5,6,7,8,9],[1,5,7,6,2,8,3,0,9,4],[5,8,0,3,7,9,6,1,4,2],[8,9,1,6,0,4,3,5,2,7],[9,4,5,3,1,2,6,8,7,0],[4,2,8,6,5,7,3,9,0,1],[2,7,9,3,8,0,6,4,1,5],[7,0,4,6,9,1,3,2,5,8]]
        var checksum = 0
        for (index, character) in number.reversed().enumerated() {
            guard let digit = Int(String(character)) else { return false }
            checksum = multiplication[checksum][permutation[index % 8][digit]]
        }
        return checksum == 0
    }
}
