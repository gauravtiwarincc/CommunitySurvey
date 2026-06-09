import SwiftUI

struct OrganizationCodeView: View {
    let themeManager: ThemeManager
    let organizationService: OrganizationServiceProtocol
    let onComplete: (Bool) -> Void

    @State private var code = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var successMessage: String?
    @State private var animate = false

    var body: some View {
        ZStack {
            AppTheme.darkGradient.ignoresSafeArea()
            
            // Soft background glows
            Circle()
                .fill(themeManager.primary.opacity(0.25))
                .frame(width: 280, height: 280)
                .blur(radius: 40)
                .offset(x: animate ? -80 : -120, y: animate ? -200 : -140)
            
            Circle()
                .fill(themeManager.secondary.opacity(0.25))
                .frame(width: 320, height: 320)
                .blur(radius: 44)
                .offset(x: animate ? 100 : 60, y: animate ? 220 : 170)

            ScrollView {
                VStack(spacing: 24) {
                    Spacer(minLength: 40)
                    
                    // Header logo / title
                    VStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .fill(.white.opacity(0.12))
                                .frame(width: 88, height: 88)
                            
                            Image(systemName: "building.2.crop.left.fill")
                                .font(.system(size: 38, weight: .bold))
                                .foregroundStyle(.white)
                        }
                        .scaleEffect(animate ? 1 : 0.88)
                        
                        Text("Connect Organization")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                        
                        Text("Enter an organization code to personalize your portal, or skip to use default branding.")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.78))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 12)
                    }
                    
                    PremiumCard {
                        VStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("ORGANIZATION CODE")
                                    .font(.caption2.weight(.bold))
                                    .foregroundStyle(.secondary)
                                
                                HStack {
                                    TextField("e.g. VON", text: $code)
                                        .textFieldStyle(.plain)
                                        .autocorrectionDisabled()
                                        .textInputAutocapitalization(.characters)
                                        .font(.headline)
                                        .foregroundStyle(.primary)
                                        .frame(height: 48)
                                    
                                    if !code.isEmpty {
                                        Button {
                                            code = ""
                                            errorMessage = nil
                                            successMessage = nil
                                        } label: {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                }
                                .padding(.horizontal, 14)
                                .background(Color(uiColor: .tertiarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                            }
                            
                            if let errorMessage {
                                ErrorBanner(message: errorMessage)
                            }
                            
                            if let successMessage {
                                successBanner(successMessage)
                            }
                            
                            GradientButton(title: isLoading ? "Verifying..." : "Apply Code & Connect", systemImage: "link.circle.fill", isEnabled: !code.trimmingCharacters(in: .whitespaces).isEmpty && !isLoading) {
                                Task { await applyCode() }
                            }
                        }
                    }
                    .padding(.horizontal, 4)
                    
                    Button {
                        onComplete(false)
                    } label: {
                        Text("Skip / Use Default Branding")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.85))
                            .padding(.vertical, 8)
                    }
                    
                    Spacer()
                }
                .padding(24)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.8)) {
                animate = true
            }
        }
        .loadingOverlay(isLoading, message: "Fetching config...")
    }

    private func successBanner(_ message: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(AppTheme.indiaGreen)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.primary)
            Spacer()
        }
        .padding(12)
        .background(AppTheme.indiaGreen.opacity(0.12), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private func applyCode() async {
        let trimmed = code.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        isLoading = true
        errorMessage = nil
        successMessage = nil
        
        do {
            try await themeManager.loadConfig(code: trimmed, using: organizationService)
            successMessage = "Branding loaded: \(themeManager.organizationName)"
            try? await Task.sleep(for: .milliseconds(750))
            onComplete(true)
        } catch {
            errorMessage = "Invalid code. Please verify your organization code."
        }
        isLoading = false
    }
}
