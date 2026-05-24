import SwiftUI

struct LoadingView: View {
    var body: some View {
        VStack(spacing: 14) {
            ShimmerView().frame(height: 118)
            ShimmerView().frame(height: 118)
            ShimmerView().frame(height: 118)
        }
        .accessibilityLabel("Loading")
    }
}
