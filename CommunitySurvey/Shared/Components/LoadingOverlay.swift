import SwiftUI

struct LoadingOverlay: ViewModifier {
    let isPresented: Bool
    let message: String

    func body(content: Content) -> some View {
        content
            .overlay {
                if isPresented {
                    ZStack {
                        Color.black.opacity(0.24).ignoresSafeArea()
                        VStack(spacing: 14) {
                            ProgressView()
                            Text(message)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .padding(22)
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel(message)
                    }
                    .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.2), value: isPresented)
    }
}

extension View {
    func loadingOverlay(_ isPresented: Bool, message: String = "Please wait") -> some View {
        modifier(LoadingOverlay(isPresented: isPresented, message: message))
    }
}
