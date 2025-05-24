import SwiftUI

struct TodoItem: Identifiable, Codable {
    var id: String
    var title: String
    var isDone: Bool
    var reminderDate: Date?
    var isQuickTic: Bool
    var reminderID: String?
}
