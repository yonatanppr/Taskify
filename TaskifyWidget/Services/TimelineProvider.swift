import Foundation
import SwiftUI
import WidgetKit


struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> TaskEntry {
        TaskEntry(date: Date(), todos: [])
    }

    func getSnapshot(in context: Context, completion: @escaping (TaskEntry) -> ()) {
        let entry = TaskEntry(date: Date(), todos: SharedStorage.loadTodos().filter {
            if let date = $0.reminderDate {
                return Calendar.current.isDateInToday(date) && !$0.isDone
            }
            return false
        })
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TaskEntry>) -> ()) {
        let currentDate = Date()
        let todos = SharedStorage.loadTodos().filter {
            if let date = $0.reminderDate {
                return Calendar.current.isDateInToday(date) && !$0.isDone
            }
            return false
        }
        let entry = TaskEntry(date: currentDate, todos: todos)
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
}
