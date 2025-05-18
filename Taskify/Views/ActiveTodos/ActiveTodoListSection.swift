import Foundation
import SwiftUI

struct ActiveTodoListSection: View {
    @Binding var todos: [TodoItem]
    let taskFilter: ActiveTodosView.TaskFilter
    //@Binding var showingDatePickerForIndex: Int? // Removed for sheet-based picker
    @Binding var reminderDate: Date
    @Binding var showConfirmation: Bool
    let reminderManager: ReminderManaging

    @State private var todoToDelete: TodoItem?
    @State private var selectedTodoForReminder: TodoItem?
    @State private var isEditingTitle = false
    @State private var editedTitle: String = ""
    @FocusState private var titleFieldIsFocused: Bool

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

        return TodoRowView(
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

    var body: some View {
        List {
            ForEach(filteredTodos, id: \.wrappedValue.id) { todoBinding in
                todoRow(for: todoBinding)
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
        .sheet(item: $selectedTodoForReminder) { todo in
            VStack(spacing: 20) {
                // Drag indicator
                Capsule()
                    .fill(Color.gray.opacity(0.4))
                    .frame(width: 40, height: 5)
                    .padding(.top, 3)
                    .padding(.bottom, 8)
                HStack {
                    if isEditingTitle {
                        TextField("Title", text: $editedTitle, onCommit: {
                            if let idx = todos.firstIndex(where: { $0.id == todo.id }) {
                                todos[idx].title = editedTitle
                            }
                            isEditingTitle = false
                            titleFieldIsFocused = false
                        })
                        .font(.headline)
                        .autocapitalization(.sentences)
                        .frame(maxWidth: .infinity)
                        .focused($titleFieldIsFocused)
                        .onAppear {
                            DispatchQueue.main.async {
                                titleFieldIsFocused = true
                            }
                        }
                        .padding(6)
                        .background(Color(.systemGray6).opacity(0.8))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.primary.opacity(0.5), lineWidth: 1)
                        )
                    } else {
                        Text(todo.title)
                            .font(.headline)
                            .padding(6)
                    }
                    Button(action: {
                        guard !todo.isDone else { return }
                        if isEditingTitle {
                            if let idx = todos.firstIndex(where: { $0.id == todo.id }) {
                                todos[idx].title = editedTitle
                            }
                            isEditingTitle = false
                            titleFieldIsFocused = false
                        } else {
                            editedTitle = todo.title
                            isEditingTitle = true
                            DispatchQueue.main.async {
                                titleFieldIsFocused = true
                            }
                        }
                    }) {
                        Image(systemName: isEditingTitle ? "checkmark" : "pencil")
                            .foregroundColor(.black)
                            .padding(.leading, 8)
                    }
                    .disabled(todo.isDone)
                }
                .padding(.horizontal)
                DatePicker(
                    "Reminder",
                    selection: $reminderDate,
                    displayedComponents: [.date, .hourAndMinute]
                )
                .datePickerStyle(.wheel)
                .labelsHidden()

                let hasReminder = todo.reminderDate != nil

                Button("Set") {
                    if let idx = todos.firstIndex(where: { $0.id == todo.id }) {
                        reminderManager.schedule(for: todos[idx], at: reminderDate) { updatedTodo in
                            DispatchQueue.main.async {
                                todos[idx].reminderDate = reminderDate
                                todos[idx].reminderID = updatedTodo.reminderID
                                selectedTodoForReminder = nil
                            }
                        }
                    } else {
                        selectedTodoForReminder = nil
                    }
                }
                .foregroundColor(.primary)

                if hasReminder {
                    Button("Remove", role: .destructive) {
                        if let idx = todos.firstIndex(where: { $0.id == todo.id }) {
                            reminderManager.remove(for: todos[idx])
                            todos[idx].reminderDate = nil
                            todos[idx].reminderID = nil
                        }
                        selectedTodoForReminder = nil
                    }
                    .foregroundColor(.red)
                } else {
                    Button("Cancel", role: .cancel) {
                        selectedTodoForReminder = nil
                    }
                    .foregroundColor(.secondary)
                }
            }
            .padding()
            .presentationBackground(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
            .presentationDetents([.medium])
            .onAppear {
                self.editedTitle = todo.title
                self.isEditingTitle = false
                self.titleFieldIsFocused = false
            }
        }
    }
}
