import SwiftUI

struct ReminderEditorCard: View {
    let todo: TodoItem
    let initialFrame: CGRect
    let reminderManager: ReminderManaging
    let onDismiss: () -> Void
    let onSave: (TodoItem) -> Void
    var namespace: Namespace.ID

    @State private var editedTitle: String
    @State private var reminderDate: Date
    @State private var animating = false

    init(
        todo: TodoItem,
        initialFrame: CGRect,
        reminderManager: ReminderManaging,
        onDismiss: @escaping () -> Void,
        onSave: @escaping (TodoItem) -> Void,
        namespace: Namespace.ID
    ) {
        self.todo = todo
        self.initialFrame = initialFrame
        self.reminderManager = reminderManager
        self.onDismiss = onDismiss
        self.onSave = onSave
        _editedTitle = State(initialValue: todo.title)
        _reminderDate = State(initialValue: todo.reminderDate ?? Date())
        self.namespace = namespace
    }

    var body: some View {
        GeometryReader { geo in
            let screen = geo.frame(in: .global)
            let animatedWidth = screen.width * (animating ? 1.0 : initialFrame.width / screen.width)
            let animatedHeight = screen.height * (animating ? 1.0 : initialFrame.height / screen.height)
            let animatedX = animating ? screen.midX : initialFrame.midX
            let animatedY = animating ? screen.midY : initialFrame.midY

            VStack {
                HStack {
                    TextField("", text: $editedTitle)
                        .font(.title)
                        .fontWeight(.bold)
                        .disabled(false)
                        .padding()
                        .matchedGeometryEffect(id: "title-\(todo.id)", in: namespace)
                    Spacer()
                }

                if animating {
                    DatePicker("Reminder", selection: $reminderDate)
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                        .padding()

                    HStack {
                        if todo.reminderDate != nil {
                            Button("Remove") {
                                var updatedTodo = todo
                                reminderManager.remove(for: updatedTodo)
                                updatedTodo.reminderDate = nil
                                updatedTodo.reminderID = nil
                                onSave(updatedTodo)

                                withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
                                    animating = false
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    onDismiss()
                                }
                            }
                            .foregroundStyle(.red)
                        } else {
                            Button("Cancel") {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
                                    animating = false
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    onDismiss()
                                }
                            }
                            .foregroundStyle(Color("TextColor"))
                        }
                        Spacer()

                        Button("Save") {
                            var updatedTodo = todo
                            updatedTodo.title = editedTitle
                            updatedTodo.reminderDate = reminderDate

                            reminderManager.schedule(for: updatedTodo, at: reminderDate) { newTodo in
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
                                    animating = false
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    onSave(updatedTodo)
                                    onDismiss()
                                }
                            }
                        }.foregroundStyle(Color("SelectedTodoAttribute"))
                    }
                    .padding()
                }

                Spacer()
            }
            .padding(.horizontal, 20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color("TodoCard"))
                    .shadow(radius: 10)
            )
            .frame(width: animatedWidth, height: animatedHeight)
            .position(x: animatedX, y: animatedY)
            .onAppear {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
                    animating = true
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}
