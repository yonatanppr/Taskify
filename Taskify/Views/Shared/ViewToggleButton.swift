import SwiftUI

struct ViewToggleButton: View {
    @Binding var isShowingCalendarView: Bool
    @Binding var showViewSelectionDialog: Bool
    
    var body: some View {
        Image(systemName: isShowingCalendarView ? "list.bullet" : "calendar") // Swapped icons to better represent target view
            .font(.system(size: 24, weight: .semibold)) // Slightly adjusted size
            // CHANGE: Icon color to white if background is blue
            .foregroundColor(.primaryText)
            .padding(20) // Adjusted padding
            // CHANGE: Background to themeOrange
            .background(Color.accentGray)
            .clipShape(Circle())
            // CHANGE: Consistent shadow
            .shadow(color: .shadowGray, radius: 8, x: 0, y: 4) // Slightly more pronounced shadow for FAB
            .position(x: UIScreen.main.bounds.width - 60, y: UIScreen.main.bounds.height - 140) // Position might need adjustment based on tab bar if one exists
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
                // ADD: Accent color for dialog buttons
            }.accentColor(.accentGray)
    }
}
