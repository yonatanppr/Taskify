import Foundation
import SwiftUI

struct ParsedTodoItem {
    let title: String
    let reminder: Date?
}

struct TodoGenerationHandler {
    static func handleNewTodoSubmission(
        text: String,
        todos: Binding<[TodoItem]>,
        isLoading: Binding<Bool>,
        errorMessage: Binding<String?>,
        reminderManager: ReminderManaging,
        onComplete: @escaping () -> Void
    ) {
        guard !text.isEmpty else { return }
        isLoading.wrappedValue = true
        errorMessage.wrappedValue = nil

        parseTodosFromText(text) { items in
            DispatchQueue.main.async {
                withAnimation(.spring()) {
                    if items.isEmpty {
                        errorMessage.wrappedValue = "Failed to generate todos. Please try again."
                        todos.wrappedValue.append(TodoItem(title: "Mock Todo"))
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                            withAnimation {
                                errorMessage.wrappedValue = nil
                            }
                        }
                    } else {
                        for parsed in items {
                            let newTodo = TodoItem(
                                title: parsed.title.trimmingCharacters(in: .whitespacesAndNewlines),
                                reminderDate: parsed.reminder
                            )

                            if let reminder = parsed.reminder {
                                print("📅 Scheduling reminder for '\(newTodo.title)' at \(reminder)")
                                reminderManager.schedule(for: newTodo, at: reminder) { updatedTodo in
                                    DispatchQueue.main.async {
                                        // Only print the outer confirmation for clarity
                                        print("✅ Reminder scheduled...")
                                        todos.wrappedValue.append(updatedTodo)
                                    }
                                }
                            } else {
                                todos.wrappedValue.append(newTodo)
                            }
                        }
                    }
                    isLoading.wrappedValue = false
                    onComplete()
                }
            }
        }
    }
}
