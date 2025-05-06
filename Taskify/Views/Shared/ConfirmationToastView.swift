import SwiftUI

struct ConfirmationToastView: View {
    var message: String

    var body: some View {
        Text(message)
            .font(.subheadline)
            .foregroundColor(.green)
            .padding(8)
            .background(Color.green.opacity(0.15))
            .cornerRadius(8)
            .transition(.scale.combined(with: .opacity))
    }
}
