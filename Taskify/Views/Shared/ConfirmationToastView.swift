import SwiftUI

struct ConfirmationToastView: View {
    var message: String

    var body: some View {
        HStack(spacing: 8) { 
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.positiveGreen)
            Text(message)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.positiveGreen)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.positiveGreen.opacity(0.15))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
        .transition(.scale(scale: 0.9, anchor: .center).combined(with: .opacity).animation(.spring(response: 0.3, dampingFraction: 0.7)))
    }
}
