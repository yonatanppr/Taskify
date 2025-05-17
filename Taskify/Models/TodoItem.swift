import SwiftUI
import Foundation


struct TodoItem: Identifiable, Codable, Equatable {
    var id = UUID()
    var title: String
    var isDone: Bool = false
    var reminderDate: Date? = nil
    var isQuickTic: Bool = false
    var reminderID: String? = nil
    
    var normalizedReminderDate: Date? {
        guard let reminderDate else { return nil }
        return Calendar.current.startOfDay(for: reminderDate)
    }
}
