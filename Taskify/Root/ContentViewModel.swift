import SwiftUI

class ContentViewModel: ObservableObject {
    @Published var todos: [TodoItem] = []
    @Published var newTodoText: String = ""
    @Published var showingDatePickerForIndex: Int? = nil
    @Published var reminderDate: Date = Date()
    @Published var isReady: Bool = false
    @Published var isShowingCalendarView: Bool = false
    @Published var showViewSelectionDialog: Bool = false

    // ADD: @MainActor to ensure UI related initializations are on the main thread
    @MainActor
    func preloadApp() async {
        todos = SharedStorage.loadTodos()
        let _ = UITextField() // Warm up UIKit text input system
        withAnimation(.easeOut(duration: 0.3)) {
            isReady = true
        }
    }
}
