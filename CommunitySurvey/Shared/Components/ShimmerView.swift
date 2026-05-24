import SwiftUI

struct ShimmerView: View {
    @State private var phase = -0.8

    var body: some View {
        RoundedRectangle(cornerRadius: 8, style: .continuous)
            .fill(Color.secondary.opacity(0.18))
            .overlay {
                GeometryReader { geometry in
                    LinearGradient(colors: [.clear, .white.opacity(0.45), .clear], startPoint: .top, endPoint: .bottom)
                        .rotationEffect(.degrees(20))
                        .offset(x: geometry.size.width * phase)
                }
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            }
            .onAppear {
                withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: false)) {
                    phase = 1.8
                }
            }
            .accessibilityHidden(true)
    }
}
