import WidgetKit
import SwiftUI


func loadTodosDueToday() -> [TodoItem] {
    guard let userDefaults = UserDefaults(suiteName: "group.com.yonatan.Taskify"),
          let data = userDefaults.data(forKey: "saved_todos") else {
        return []
    }
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    do {
        let todos = try decoder.decode([TodoItem].self, from: data)
        UserDefaults.standard.set(todos.count, forKey: "widget_todo_count_debug")
        return todos.filter {
            if let reminderDate = $0.reminderDate {
                return Calendar.current.isDateInToday(reminderDate) && !$0.isDone
            }
            return false
        }
    } catch {
        return []
    }
}
