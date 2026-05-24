import SwiftUI

struct SplashView: View {
    let onComplete: () -> Void
    @State private var animate = false

    var body: some View {
        ZStack {
            AppTheme.darkGradient.ignoresSafeArea()
            Circle()
                .fill(AppTheme.saffron.opacity(0.34))
                .frame(width: 260, height: 260)
                .blur(radius: 40)
                .offset(x: animate ? -90 : -130, y: animate ? -220 : -160)
            Circle()
                .fill(AppTheme.indiaGreen.opacity(0.34))
                .frame(width: 300, height: 300)
                .blur(radius: 44)
                .offset(x: animate ? 120 : 80, y: animate ? 240 : 190)
            VStack(spacing: 22) {
                ZStack {
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .fill(.white.opacity(0.12))
                        .frame(width: 104, height: 104)
                    Image(systemName: "checkmark.shield.fill")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundStyle(.white)
                }
                .scaleEffect(animate ? 1 : 0.84)
                VStack(spacing: 8) {
                    Text("Verified Opinion Network")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white)
                    Text("भारत का Verified Public Opinion Platform")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white.opacity(0.82))
                }
            }
            .padding(28)
            .opacity(animate ? 1 : 0)
            .offset(y: animate ? 0 : 24)
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.82)) { animate = true }
            Task {
                try? await Task.sleep(for: .milliseconds(1300))
                onComplete()
            }
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    SplashView(onComplete: { })
}
