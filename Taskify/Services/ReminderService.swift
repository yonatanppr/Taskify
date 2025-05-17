protocol ReminderManaging {
    func schedule(for todo: TodoItem, at date: Date, completion: @escaping (TodoItem) -> Void)
    func remove(for todo: TodoItem)
}
import Foundation
import UserNotifications


struct ReminderService {
    static func scheduleReminder(for todo: TodoItem, at date: Date, completion: @escaping (TodoItem) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    scheduleNotification(for: todo, at: date) { updatedTodo in
                        completion(updatedTodo)
                    }
                }
            } else {
                print("❌ Notification permission not granted: \(String(describing: error))")
            }
        }
    }
    
    private static func scheduleNotification(for todo: TodoItem, at date: Date, completion: @escaping (TodoItem) -> Void) {
        var updatedTodo = todo
        let identifier = UUID().uuidString
        updatedTodo.reminderID = identifier
        
        let content = UNMutableNotificationContent()
        content.title = "Reminder"
        content.body = todo.title
        content.sound = .default

        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)

        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Failed to schedule reminder: \(error)")
            } else {
                print("✅ Reminder scheduled for \(todo.title) at \(date)")
                completion(updatedTodo)
            }
        }
    }
    
    static func removeReminder(for todo: TodoItem) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { _ in
            if let id = todo.reminderID {
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
                print("🗑️ Removed reminder with ID \(id) for \(todo.title)")
            } else {
                print("⚠️ No reminderID found for \(todo.title). Nothing was removed.")
            }
        }
    }
}

extension ReminderService: ReminderManaging {
    func schedule(for todo: TodoItem, at date: Date, completion: @escaping (TodoItem) -> Void) {
        ReminderService.scheduleReminder(for: todo, at: date, completion: completion)
    }

    func remove(for todo: TodoItem) {
        ReminderService.removeReminder(for: todo)
    }
}
