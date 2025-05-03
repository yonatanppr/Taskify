import Foundation
import UserNotifications

struct ReminderService {
    static func scheduleReminder(for title: String, at date: Date) {
        let content = UNMutableNotificationContent()
        content.title = "Reminder"
        content.body = title
        content.sound = .default

        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Failed to schedule reminder: \(error)")
            } else {
                print("✅ Reminder scheduled for \(title)")
            }
        }
    }
}
