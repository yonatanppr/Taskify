import Foundation
import WidgetKit

struct TodoStorage {
    private static let key = "saved_todos"
    private static let suiteName = "group.com.yonatan.Taskify"

    static var userDefaults: UserDefaults? {
        UserDefaults(suiteName: suiteName)
    }

    static func save(_ todos: [TodoItem]) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        if let encoded = try? encoder.encode(todos) {
            userDefaults?.set(encoded, forKey: key)
            WidgetCenter.shared.reloadTimelines(ofKind: "TaskifyWidget")
        }
        if let data = TodoStorage.userDefaults?.data(forKey: "saved_todos") {
            print("Saved data size: \(data.count)")
        } else {
            print("No data saved.")
        }
        if let data = TodoStorage.userDefaults?.data(forKey: "saved_todos"),
           let json = String(data: data, encoding: .utf8) {
            print("RAW TODOS JSON:", json)
        } else {
            print("Could not get raw JSON.")
        }
    }

    static func load() -> [TodoItem] {
        guard let data = userDefaults?.data(forKey: key) else {
            return []
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        if let todos = try? decoder.decode([TodoItem].self, from: data) {
            return todos
        } else {
            return []
        }
    }
}
