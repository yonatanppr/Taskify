import Foundation

struct TodoStorage {
    private static let key = "saved_todos"

    static func save(_ todos: [TodoItem]) {
        if let encoded = try? JSONEncoder().encode(todos) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }

    static func load() -> [TodoItem] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let todos = try? JSONDecoder().decode([TodoItem].self, from: data) else {
            return []
        }
        return todos
    }
}

// Note: `TodoItem` must conform to `Codable`, and include a default value for `isQuickTic` (e.g., `isQuickTic: Bool = false`)
// to ensure older saved data without this property can still be decoded safely.
