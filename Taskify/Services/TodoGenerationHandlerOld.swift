import SwiftUI

struct TodoGenerationHandlerOld {
    static func handleNewTodoSubmission(
        text: String,
        todos: Binding<[TodoItem]>,
        isLoading: Binding<Bool>,
        errorMessage: Binding<String?>,
        reminderManager: ReminderManaging,
        onComplete: @escaping () -> Void
    ) async {
        guard !text.isEmpty else { return }
        isLoading.wrappedValue = true
        errorMessage.wrappedValue = nil

        do {
            let items = try await LLMService.shared.generateTodos(from: text)
            await MainActor.run {
                if items.isEmpty {
                    errorMessage.wrappedValue = "Failed to generate todos. Please try again."
                } else {
                    for parsed in items {
                        let newTodo = TodoItem(
                            title: parsed.title.trimmingCharacters(in: .whitespacesAndNewlines),
                            reminderDate: parsed.reminder
                        )
                        if let reminder = parsed.reminder {
                            reminderManager.schedule(for: newTodo, at: reminder) { updatedTodo in
                                todos.wrappedValue.append(updatedTodo)
                            }
                        } else {
                            todos.wrappedValue.append(newTodo)
                        }
                    }
                }
                isLoading.wrappedValue = false
                onComplete()
            }
        } catch {
            await MainActor.run {
                errorMessage.wrappedValue = "Failed to generate todos. Please try again."
                isLoading.wrappedValue = false
                onComplete()
            }
        }
    }
}
