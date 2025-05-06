
import SwiftUI

class ContentViewModel: ObservableObject {
    @Published var todos: [TodoItem] = []
    @Published var newTodoText: String = ""
    @Published var showingDatePickerForIndex: Int? = nil
    @Published var reminderDate: Date = Date()
    @Published var showConfirmation: Bool = false
    @Published var isReady: Bool = false
    @Published var isShowingCalendarView: Bool = false
    @Published var showViewSelectionDialog: Bool = false
    
    @MainActor
    func preloadApp() async {
        todos = TodoStorage.load()
        let _ = UITextField() // Warm up UIKit text input system
        withAnimation(.easeOut(duration: 0.3)) {
            isReady = true
        }
    }
}
