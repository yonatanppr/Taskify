import SwiftUI
import Foundation


struct TodoItem: Identifiable, Codable, Equatable {
    var id = UUID()
    var title: String
    var isDone: Bool = false
    var reminderDate: Date? = nil
}
