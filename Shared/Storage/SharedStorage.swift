import Foundation
import WidgetKit

struct SharedStorage {
    private static let key = "saved_todos"
    private static let suiteName = "group.com.yonatan.Taskify"

    private static var defaults: UserDefaults? {
        UserDefaults(suiteName: suiteName)
    }

    static func loadTodos() -> [TodoItem] {
        guard let data = defaults?.data(forKey: key) else { return [] }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return (try? decoder.decode([TodoItem].self, from: data)) ?? []
    }

    static func saveTodos(_ todos: [TodoItem]) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(todos) else { return }
        defaults?.set(data, forKey: key)
        WidgetCenter.shared.reloadTimelines(ofKind: "TaskifyWidget")
    }
}
