import SwiftUI
import Foundation


struct TodoItem: Identifiable {
    let id = UUID()
    let title: String
    var isDone: Bool = false
    var reminderDate: Date? = nil
}



struct ReminderManager: ReminderManaging {
    func schedule(for todo: TodoItem, at date: Date, completion: @escaping (TodoItem) -> Void) {
        let content = UNMutableNotificationContent()
        content.title = "To-Do Reminder"
        content.body = todo.title
        content.sound = .default

        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            var updated = todo
            if let error = error {
                print("❌ Failed to schedule reminder: \(error)")
            } else {
                print("✅ Reminder scheduled for \(todo.title) at \(date)")
            }
            completion(updated)
        }
    }

    func remove(for todo: TodoItem) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let matches = requests
                .filter { $0.content.body == todo.title }
                .map { $0.identifier }

            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: matches)
            print("🗑️ Removed reminder for \(todo.title)")
        }
    }
}
