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
