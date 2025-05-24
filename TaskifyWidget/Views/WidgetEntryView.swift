import Foundation
import SwiftUI

struct WidgetEntryView: View {
    var entry: TaskEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if entry.todos.isEmpty {
                Text("No tasks due today.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                ForEach(entry.todos.prefix(3)) { todo in
                    Text(todo.title)
                        .font(.caption)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                }
            }
        }
        .padding()
    }
}
