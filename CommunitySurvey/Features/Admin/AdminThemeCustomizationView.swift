import SwiftUI

struct AdminThemeCustomizationView: View {
    @State var viewModel: AdminThemeCustomizationViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Live Branding Preview Card
                brandingPreviewSection
                
                // Branding Settings Form
                brandingFormSection
                
                // Save Button
                saveActionButton
            }
            .padding(20)
        }
        .background(AppTheme.softGradient.ignoresSafeArea())
        .navigationTitle("Customize Branding")
        .navigationBarTitleDisplayMode(.inline)
        .overlay {
            if viewModel.isLoading {
                LoadingOverlayView()
            }
        }
        .alert("Success", isPresented: $viewModel.saveSuccess) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Branding settings saved and applied successfully!")
        }
    }
    
    private var brandingPreviewSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Live Preview")
                .font(.subheadline.bold())
                .foregroundStyle(.secondary)
                .padding(.horizontal, 4)
            
            // Preview Card rendering in real time
            VStack(spacing: 0) {
                // Brand Header with Gradient
                VStack(spacing: 16) {
                    if !viewModel.logoUrl.isEmpty, let url = URL(string: viewModel.logoUrl) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 44)
                                .shadow(radius: 2)
                        } placeholder: {
                            Image(systemName: "photo")
                                .font(.title)
                                .foregroundStyle(.white.opacity(0.8))
                        }
                    } else {
                        Image(systemName: "building.columns.fill")
                            .font(.system(size: 36))
                            .foregroundStyle(.white)
                    }
                    
                    VStack(spacing: 4) {
                        Text(viewModel.organizationName.isEmpty ? "Organization Name" : viewModel.organizationName)
                            .font(.title2.bold())
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                        
                        if !viewModel.welcomeMessage.isEmpty {
                            Text(viewModel.welcomeMessage)
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.85))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 16)
                        }
                    }
                }
                .padding(.vertical, 28)
                .frame(maxWidth: .infinity)
                .background(
                    LinearGradient(
                        colors: [viewModel.primaryColor, viewModel.secondaryColor],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                
                // Preview Body showing accent action elements
                VStack(spacing: 14) {
                    Text("Survey Dashboard Preview")
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                    
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Reward Points")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            Text("1,250 pts")
                                .font(.headline.bold())
                                .foregroundStyle(viewModel.primaryColor)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Accent Button")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            Text("Action View")
                                .font(.headline.bold())
                                .foregroundStyle(viewModel.accentColor)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                    
                    // Sample Submit Button in accent color
                    Text("Sample Button")
                        .font(.subheadline.bold())
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(viewModel.accentColor)
                        .cornerRadius(12)
                }
                .padding(18)
                .background(AppTheme.surface)
            }
            .cornerRadius(22)
            .shadow(color: .black.opacity(0.08), radius: 14, x: 0, y: 6)
        }
    }
    
    private var brandingFormSection: some View {
        VStack(spacing: 16) {
            // General Info
            PremiumCard(padding: 16) {
                VStack(alignment: .leading, spacing: 14) {
                    Text("General Details")
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .padding(.bottom, 2)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Organization Name")
                            .font(.caption.bold())
                            .foregroundStyle(.secondary)
                        TextField("e.g. Innovate Academy", text: $viewModel.organizationName)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Welcome Message")
                            .font(.caption.bold())
                            .foregroundStyle(.secondary)
                        TextField("e.g. Welcome to Innovate Portal!", text: $viewModel.welcomeMessage)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Support Email")
                            .font(.caption.bold())
                            .foregroundStyle(.secondary)
                        TextField("e.g. contact@innovate.edu", text: $viewModel.supportEmail)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.emailAddress)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Logo URL")
                            .font(.caption.bold())
                            .foregroundStyle(.secondary)
                        TextField("e.g. https://domain.com/logo.png", text: $viewModel.logoUrl)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.URL)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                    }
                }
            }
            
            // Color Pickers
            PremiumCard(padding: 16) {
                VStack(alignment: .leading, spacing: 14) {
                    Text("Theme Palette")
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .padding(.bottom, 2)
                    
                    ColorPicker(selection: $viewModel.primaryColor, supportsOpacity: false) {
                        HStack(spacing: 12) {
                            Circle()
                                .fill(viewModel.primaryColor)
                                .frame(width: 16, height: 16)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Primary Color")
                                    .font(.subheadline.bold())
                                Text("Main branding elements and gradients")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    
                    Divider()
                    
                    ColorPicker(selection: $viewModel.secondaryColor, supportsOpacity: false) {
                        HStack(spacing: 12) {
                            Circle()
                                .fill(viewModel.secondaryColor)
                                .frame(width: 16, height: 16)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Secondary Color")
                                    .font(.subheadline.bold())
                                Text("Gradient ends and secondary highlights")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    
                    Divider()
                    
                    ColorPicker(selection: $viewModel.accentColor, supportsOpacity: false) {
                        HStack(spacing: 12) {
                            Circle()
                                .fill(viewModel.accentColor)
                                .frame(width: 16, height: 16)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Accent Color")
                                    .font(.subheadline.bold())
                                Text("Primary buttons and call-to-actions")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private var saveActionButton: some View {
        VStack(spacing: 12) {
            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
            }
            
            Button {
                Task {
                    await viewModel.saveTheme()
                }
            } label: {
                Text("Save & Apply Branding")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(
                            colors: [viewModel.primaryColor, viewModel.secondaryColor],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(14)
                    .shadow(color: viewModel.primaryColor.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            .disabled(viewModel.organizationName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
    }
}

// Custom Loading Overlay View to match clean design
struct LoadingOverlayView: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.2)
                    .tint(.white)
                Text("Saving Branding Settings...")
                    .font(.subheadline.bold())
                    .foregroundStyle(.white)
            }
            .padding(24)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
    }
}
