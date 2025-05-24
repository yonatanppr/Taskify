import SwiftUI
import WidgetKit

struct TaskEntry: TimelineEntry {
    let date: Date
    let todos: [TodoItem]
}
