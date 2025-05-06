import SwiftUI

struct LaunchScreenView: View {
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            VStack(spacing: 12) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                    .scaleEffect(1.5)
                Text("Preparing your tasks...")
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
        }
    }
}
