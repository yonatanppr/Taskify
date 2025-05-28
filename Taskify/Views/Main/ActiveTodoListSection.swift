import Foundation
import SwiftUI

struct ActiveTodoListSection: View {
    @Binding var todos: [TodoItem]
    let taskFilter: ActiveTodosView.TaskFilter
    //@Binding var showingDatePickerForIndex: Int? // Removed for sheet-based picker
    @Binding var reminderDate: Date
    let reminderManager: ReminderManaging

    @State private var todoToDelete: TodoItem?

    private var filteredTodos: [Binding<TodoItem>] {
        switch taskFilter {
        case .all:
            return $todos.reversed().filter { !$0.wrappedValue.isDone }
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
        case .quickTics:
            return $todos.filter { $0.wrappedValue.isQuickTic && !$0.wrappedValue.isDone }
        case .today:
            let calendar = Calendar.current
            return $todos.filter {
                guard let date = $0.wrappedValue.reminderDate else { return false }
                return calendar.isDateInToday(date) && !$0.wrappedValue.isDone
            }
        }
    }

    private func todoRow(for todoBinding: Binding<TodoItem>) -> some View {
        let onToggle = {
            withAnimation(.easeInOut(duration: 0.25)) {
                let wasDone = todoBinding.wrappedValue.isDone
                todoBinding.isDone.wrappedValue.toggle()
                let isNowDone = todoBinding.wrappedValue.isDone

                if !wasDone && isNowDone {
                    let todoForReminderRemoval = todoBinding.wrappedValue
                    if let rId = todoForReminderRemoval.reminderID {
                        print(" Removing reminder for '\(todoForReminderRemoval.title)' with ID: \(rId)")
                    } else {
                        print(" Removing reminder for '\(todoForReminderRemoval.title)' (item had no reminderID when toggled to done)")
                    }
                    reminderManager.remove(for: todoForReminderRemoval)
                    if let index = todos.firstIndex(where: { $0.id == todoForReminderRemoval.id }) {
                        todos[index].reminderDate = nil
                        todos[index].reminderID = nil
                    }
                }
            }
        }

        return TodoRowView(
            todo: todoBinding.wrappedValue,
            reminderDate: $reminderDate,
            onToggle: onToggle,
            onBellTap: {
                if let date = todoBinding.reminderDate.wrappedValue {
                    reminderDate = date
                } else {
                    reminderDate = Date()
                }
            },
            onQuickTicToggle: {
                if let index = todos.firstIndex(where: { $0.id == todoBinding.id }) {
                    todos[index].isQuickTic.toggle()
                }
            },
            onUpdate: { updatedTodo in
                if let index = todos.firstIndex(where: { $0.id == updatedTodo.id }) {
                    todos[index] = updatedTodo
                }
            },
            onRemoveReminder: { todoToRemove in
                if let index = todos.firstIndex(where: { $0.id == todoToRemove.id }) {
                    todos[index].reminderDate = nil
                    todos[index].reminderID = nil
                }
            },
            reminderManager: reminderManager
        )
        .listRowInsets(EdgeInsets())
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                todoToDelete = todoBinding.wrappedValue
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .background(Color.clear)
        .cornerRadius(12)
        .padding(.horizontal)
        .padding(.vertical, 6)
    }

    var body: some View {
        List {
            ForEach(filteredTodos, id: \.wrappedValue.id) { todoBinding in
                todoRow(for: todoBinding)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.25), value: filteredTodos.map { $0.wrappedValue.id })
        .padding(.bottom, 120) // adjust as needed based on card height
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color.clear)
        .alert(item: $todoToDelete) { todo in
            Alert(
                title: Text("Delete Task?"),
                message: Text("Are you sure you want to delete '\(todo.title)'?"),
                primaryButton: .destructive(Text("Delete")) {
                    if let index = todos.firstIndex(where: { $0.id == todo.id }) {
                        todos.remove(at: index)
                    }
                },
                secondaryButton: .cancel()
            )
        }
    }
}
