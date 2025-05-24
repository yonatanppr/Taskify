import SwiftUI

struct TodoGenerationHandler {
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

        // Use on-device parser instead of LLMService
        let parsed = NaturalLanguageParser.shared.parse(text)
        await MainActor.run {
            if parsed.title.isEmpty {
                errorMessage.wrappedValue = "Failed to parse todo. Please try again."
            } else {
                let newTodo = TodoItem(
                    id: UUID().uuidString,
                    title: parsed.title.trimmingCharacters(in: .whitespacesAndNewlines),
                    reminderDate: parsed.reminderDate
                )
                if let reminder = parsed.reminderDate {
                    reminderManager.schedule(for: newTodo, at: reminder) { updatedTodo in
                        todos.wrappedValue.append(updatedTodo)
                    }
                } else {
                    todos.wrappedValue.append(newTodo)
                }
            }
            isLoading.wrappedValue = false
            onComplete()
        }
    }
}
