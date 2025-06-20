import SwiftUI
import UIKit

@MainActor
class ContentViewModel: ObservableObject {
    @Published var todos: [TodoItem] = []
    @Published var newTodoText: String = ""
    @Published var showingDatePickerForIndex: Int? = nil
    @Published var reminderDate: Date = Date()
    @Published var isReady: Bool = false
    @Published var isShowingCalendarView: Bool = false
    @Published var showViewSelectionDialog: Bool = false

    func preloadApp() async {
        todos = SharedStorage.loadTodos()
        let _ = UITextField()
        let _ = UITextView()
        let _ = UISearchBar()
        let _ = UIDatePicker()
        withAnimation(.easeOut(duration: 0.1)) {
            isReady = true
       }
    }
}
