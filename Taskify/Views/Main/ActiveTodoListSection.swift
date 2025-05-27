import Foundation
import SwiftUI

struct ActiveTodoListSection: View {
    @Binding var todos: [TodoItem]
    let taskFilter: ActiveTodosView.TaskFilter
    //@Binding var showingDatePickerForIndex: Int? // Removed for sheet-based picker
    @Binding var reminderDate: Date
    let reminderManager: ReminderManaging

    @State private var todoToDelete: TodoItem?
    @Binding var selectedTodoForReminder: TodoItem?
    @Namespace private var reminderTransitionNamespace
    @Binding var selectedTodoFrame: CGRect?

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
                    todoBinding.reminderDate.wrappedValue = nil
                    todoBinding.reminderID.wrappedValue = nil
                }
            }
        }

        return GeometryReader { geometry in
            TodoRowView(
                todo: todoBinding.wrappedValue,
                reminderDate: $reminderDate,
                onToggle: onToggle,
                onBellTap: {
                    selectedTodoForReminder = todoBinding.wrappedValue
                    if let date = todoBinding.reminderDate.wrappedValue {
                        reminderDate = date
                    } else {
                        reminderDate = Date()
                    }
                    selectedTodoFrame = geometry.frame(in: .global)
                },
                onQuickTicToggle: {
                    if let index = todos.firstIndex(where: { $0.id == todoBinding.id }) {
                        todos[index].isQuickTic.toggle()
                    }
                },
                namespace: reminderTransitionNamespace
            )
            .background(GeometryPreferenceSetter())
        }
        .frame(height: 60) // or appropriate height for TodoRowView
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
        .onPreferenceChange(GeometryPreferenceKey.self) { value in
            if selectedTodoForReminder?.id == todoBinding.wrappedValue.id {
                selectedTodoFrame = value
            }
        }
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

private struct GeometryPreferenceKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}

private struct GeometryPreferenceSetter: View {
    var body: some View {
        GeometryReader { geometry in
            Color.clear.preference(key: GeometryPreferenceKey.self, value: geometry.frame(in: .global))
        }
    }
}
