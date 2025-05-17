import Foundation
import SwiftUI

struct ActiveTodoListSection: View {
    @Binding var todos: [TodoItem]
    let taskFilter: ActiveTodosView.TaskFilter
    @Binding var showingDatePickerForIndex: Int?
    @Binding var reminderDate: Date
    @Binding var showConfirmation: Bool
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
        //case .completed:
            //return $todos.filter { $0.wrappedValue.isDone }
        case .quickTics:
            return $todos.filter { $0.wrappedValue.isQuickTic && !$0.wrappedValue.isDone }
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
                            todoBinding.reminderID.wrappedValue = nil
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
                    },
                    onQuickTicToggle: {
                        if let index = todos.firstIndex(where: { $0.id == todoBinding.id }) {
                            todos[index].isQuickTic.toggle()
                        }
                    }
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
        }
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
