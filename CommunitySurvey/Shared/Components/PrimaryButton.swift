import SwiftUI

struct PrimaryButton: View {
    let title: String
    var systemImage: String? = nil
    var isEnabled = true
    let action: () -> Void

    var body: some View {
        GradientButton(title: title, systemImage: systemImage, isEnabled: isEnabled, action: action)
    }
}
