import SwiftUI

struct ReminderSheetView: View {
    @Binding var reminderDate: Date
    @Binding var isPresented: Bool
    @Binding var todos: [TodoItem]
    let todo: TodoItem
    let reminderManager: ReminderManaging

    @State private var editedTitle: String
    @FocusState private var titleFieldIsFocused: Bool
    @State private var isEditingTitle = false

    init(reminderDate: Binding<Date>, isPresented: Binding<Bool>, todos: Binding<[TodoItem]>, todo: TodoItem, reminderManager: ReminderManaging) {
        self._reminderDate = reminderDate
        self._isPresented = isPresented
        self._todos = todos
        self.todo = todo
        self.reminderManager = reminderManager
        self._editedTitle = State(initialValue: todo.title)
    }

    var body: some View {
        VStack(spacing: 20) {
            Capsule()
                .frame(width: 40, height: 6)
                .foregroundColor(.gray.opacity(0.4))
                .padding(.top, 10)

            HStack {
                if isEditingTitle {
                    TextField("", text: $editedTitle)
                        .font(.title)
                        .fontWeight(.bold)
                        .focused($titleFieldIsFocused)
                        .onSubmit {
                            isEditingTitle = false
                            titleFieldIsFocused = false
                        }
                } else {
                    Text(todo.title)
                        .font(.title)
                        .fontWeight(.bold)
                        .onTapGesture {
                            isEditingTitle = true
                            titleFieldIsFocused = true
                        }
                }
                Spacer()
            }
            .padding(.horizontal)

            DatePicker("", selection: $reminderDate)
                .datePickerStyle(.wheel)
                .labelsHidden()
                .frame(maxWidth: .infinity)
                .padding(.horizontal)

            HStack(spacing: 20) {
                if todo.reminderDate != nil {
                    Button("Remove") {
                        reminderManager.remove(for: todo)
                        if let index = todos.firstIndex(where: { $0.id == todo.id }) {
                            todos[index].reminderDate = nil
                            todos[index].reminderID = nil
                        }
                        isPresented = false
                    }
                    .foregroundColor(.red)
                }

                Button("Set") {
                    var updatedTodo = todo
                    updatedTodo.title = editedTitle
                    updatedTodo.reminderDate = reminderDate

                    if let index = todos.firstIndex(where: { $0.id == updatedTodo.id }) {
                        todos[index].title = editedTitle
                        todos[index].reminderDate = reminderDate
                    }

                    reminderManager.schedule(for: updatedTodo, at: reminderDate) { newTodo in
                        if let index = todos.firstIndex(where: { $0.id == newTodo.id }) {
                            todos[index] = newTodo
                        }
                        isPresented = false
                    }
                }
                .foregroundColor(.blue)
            }
            .padding(.bottom, 20)
        }
        .presentationDetents([.medium])
    }
}
