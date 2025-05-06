
import SwiftUI

struct ViewToggleButton: View {
    @Binding var isShowingCalendarView: Bool
    @Binding var showViewSelectionDialog: Bool
    
    var body: some View {
        Image(systemName: isShowingCalendarView ? "pencil" : "calendar")
            .font(.system(size: 26, weight: .semibold))
            .foregroundColor(.primary)
            .padding(22)
            .background(Color.white.opacity(0.95))
            .clipShape(Circle())
            .shadow(radius: 4)
            .position(x: UIScreen.main.bounds.width - 60, y: UIScreen.main.bounds.height - 140)
            .zIndex(100)
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.35)) {
                    isShowingCalendarView.toggle()
                }
            }
            .onLongPressGesture {
                showViewSelectionDialog = true
            }
            .confirmationDialog("Select View", isPresented: $showViewSelectionDialog, titleVisibility: .visible) {
                Button("Todos") {
                    withAnimation(.easeInOut(duration: 0.35)) {
                        isShowingCalendarView = false
                    }
                }
                Button("Calendar") {
                    withAnimation(.easeInOut(duration: 0.35)) {
                        isShowingCalendarView = true
                    }
                }
            }
    }
}
