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
        let updatedTodo = todo
        
        let content = UNMutableNotificationContent()
        content.title = "Reminder"
        content.body = todo.title
        content.sound = .default

        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

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
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let matchingIdentifiers = requests
                .filter { $0.content.body == todo.title }
                .map { $0.identifier }
            
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: matchingIdentifiers)
            print("🗑️ Removed reminder for \(todo.title)")
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
