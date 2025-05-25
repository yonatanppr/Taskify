import SwiftUI
import Foundation

struct HeaderBarView: View {
    @Binding var showingSettings: Bool
    @State var currentDateText: String = ""
    var body: some View {
        HStack(spacing: 12) {
            Button(action: {}) {
                Image("ProfileIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .padding(12)
                    .foregroundColor(Color("ButtonIcon"))  // Optional
                    .background(
                        ZStack {
                            Color.clear.background(.ultraThinMaterial)
                            Color("UnselectedFilter")
                        }
                    )
                    .clipShape(Circle())
            }
            
            Button(action: { showingSettings = true }) {
                Image("SettingsIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .padding(12)
                    .foregroundColor(Color("ButtonIcon"))  // Optional
                    .background(
                        ZStack {
                            Color.clear.background(.ultraThinMaterial)
                            Color("UnselectedFilter")
                        }
                    )
                    .clipShape(Circle())
            }
            
            Spacer()
            
            Text(currentDateText)
                .font(.system(size: 65, weight: .bold, design: .rounded))
                .foregroundColor(Color("DateColor"))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .truncationMode(.tail)
        }
        .padding(.horizontal, 20)
        .padding(.top, 35)
        .onAppear {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd MMMM"
            currentDateText = formatter.string(from: Date())
        }
    }
}
