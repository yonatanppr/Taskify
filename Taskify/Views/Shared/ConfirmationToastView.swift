import SwiftUI

struct ConfirmationToastView: View {
    var message: String

    var body: some View {
        HStack(spacing: 8) { 
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.white)
            Text(message)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.white)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.positiveGreen)
        .cornerRadius(10)
        .shadow(color: .shadowGray, radius: 3, x: 0, y: 2)
        .transition(.scale(scale: 0.9, anchor: .center).combined(with: .opacity).animation(.spring(response: 0.3, dampingFraction: 0.7)))
    }
}
