import Foundation
import SwiftUI
import WidgetKit


struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> TaskEntry {
        TaskEntry(date: Date(), todos: [])
    }

    func getSnapshot(in context: Context, completion: @escaping (TaskEntry) -> ()) {
        let entry = TaskEntry(date: Date(), todos: loadTodosDueToday())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TaskEntry>) -> ()) {
        let currentDate = Date()
        let todos = loadTodosDueToday()
        let entry = TaskEntry(date: currentDate, todos: todos)
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
}
