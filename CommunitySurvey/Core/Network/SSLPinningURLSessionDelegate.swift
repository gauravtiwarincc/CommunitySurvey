import Foundation
import CryptoKit
import OSLog

final class SSLPinningURLSessionDelegate: NSObject, URLSessionDelegate {
    private let pinnedSHA256Hashes: [String: Set<String>]

    init(pinnedSHA256Hashes: [String: Set<String>] = [:]) {
        self.pinnedSHA256Hashes = pinnedSHA256Hashes
    }

    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge) async -> (URLSession.AuthChallengeDisposition, URLCredential?) {
        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
              let serverTrust = challenge.protectionSpace.serverTrust,
              let hostHashes = pinnedSHA256Hashes[challenge.protectionSpace.host],
              !hostHashes.isEmpty else {
            return (.performDefaultHandling, nil)
        }

        let certificateCount = SecTrustGetCertificateCount(serverTrust)
        for index in 0..<certificateCount {
            guard let certificate = SecTrustGetCertificateAtIndex(serverTrust, index) else { continue }
            let data = SecCertificateCopyData(certificate) as Data
            let hash = SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
            if hostHashes.contains(hash) {
                return (.useCredential, URLCredential(trust: serverTrust))
            }
        }
        AppLogger.security.error("SSL pinning failed for host: \(challenge.protectionSpace.host, privacy: .public)")
        return (.cancelAuthenticationChallenge, nil)
    }
}
