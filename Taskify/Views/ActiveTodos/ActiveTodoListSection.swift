import Foundation
import SwiftUI

struct ActiveTodoListSection: View {
    @Binding var todos: [TodoItem]
    let taskFilter: ActiveTodosView.TaskFilter
    @Binding var showingDatePickerForIndex: Int?
    @Binding var reminderDate: Date
    @Binding var showConfirmation: Bool
    let reminderManager: ReminderManaging

    private var filteredTodos: [Binding<TodoItem>] {
        switch taskFilter {
        case .all:
            return $todos.filter { !$0.wrappedValue.isDone }
        case .upcoming:
            return $todos
                .filter {
                    guard let date = $0.wrappedValue.reminderDate else { return false }
                    return date > Date() && !$0.wrappedValue.isDone
                }
                .sorted {
                    guard let d1 = $0.wrappedValue.reminderDate, let d2 = $1.wrappedValue.reminderDate else { return false }
                    return d1 < d2
                }
        case .completed:
            return $todos.filter { $0.wrappedValue.isDone }
        }
    }

    var body: some View {
        List {
            ForEach(filteredTodos, id: \.wrappedValue.id) { todoBinding in

                let onToggle = {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        todoBinding.isDone.wrappedValue.toggle()
                        if todoBinding.isDone.wrappedValue {
                            print(" Removing reminder for '\(todoBinding.title.wrappedValue)'")
                            todoBinding.reminderDate.wrappedValue = nil
                            reminderManager.remove(for: todoBinding.wrappedValue)
                        }
                    }
                }

                TodoRowView(
                    todo: todoBinding.wrappedValue,
                    reminderDate: $reminderDate,
                    onToggle: onToggle,
                    onBellTap: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            if let index = todos.firstIndex(where: { $0.id == todoBinding.id }) {
                                if showingDatePickerForIndex == index {
                                    showingDatePickerForIndex = nil
                                } else {
                                    if let existingDate = todoBinding.reminderDate.wrappedValue {
                                        reminderDate = existingDate
                                    } else {
                                        reminderDate = Date()
                                    }
                                    showingDatePickerForIndex = index
                                }
                            }
                        }
                    }
                )
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button {
                        onToggle()
                    } label: {
                        Label("Complete", systemImage: "checkmark")
                    }
                    .tint(.positiveGreen)
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color.clear)
    }
}
