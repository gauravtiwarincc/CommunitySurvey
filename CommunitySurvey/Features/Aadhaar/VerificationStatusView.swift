import SwiftUI

struct VerificationStatusView: View {
    let result: AadhaarVerificationResult
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer(minLength: 24)
            Image(systemName: iconName)
                .font(.system(size: 72, weight: .semibold))
                .foregroundStyle(statusColor)
                .symbolEffect(.bounce, value: result.status)
            VStack(spacing: 8) {
                Text(title)
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)
                Text(result.message)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            PremiumCard {
                VStack(spacing: 14) {
                    row(title: "Reference ID", value: result.referenceID)
                    row(title: "Aadhaar", value: result.maskedAadhaar)
                    if let verifiedAt = result.verifiedAt {
                        row(title: "Verified at", value: verifiedAt.formatted(date: .abbreviated, time: .shortened))
                    }
                }
            }
            Spacer()
            GradientButton(title: "Go to Dashboard", systemImage: "chart.bar.xaxis") {
                onContinue()
            }
        }
        .padding(20)
        .background(AppTheme.softGradient.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
    }

    private var title: String {
        switch result.status {
        case .verified: return "Identity Verified"
        case .pending: return "Verification Pending"
        case .failed: return "Verification Failed"
        }
    }

    private var iconName: String {
        switch result.status {
        case .verified: return "checkmark.seal.fill"
        case .pending: return "clock.badge.checkmark"
        case .failed: return "xmark.seal.fill"
        }
    }

    private var statusColor: Color {
        switch result.status {
        case .verified: return AppTheme.indiaGreen
        case .pending: return AppTheme.saffron
        case .failed: return .red
        }
    }

    private func row(title: String, value: String) -> some View {
        HStack {
            Text(title).foregroundStyle(.secondary)
            Spacer(minLength: 12)
            Text(value).font(.body.monospacedDigit()).multilineTextAlignment(.trailing)
        }
        .font(.subheadline)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    VerificationStatusView(
        result: AadhaarVerificationResult(referenceID: "AAD-123456", maskedAadhaar: "XXXX XXXX 0019", status: .verified, message: "Aadhaar verification completed successfully.", verifiedAt: Date()),
        onContinue: { }
    )
}
