import SwiftUI

struct ActiveTodoListSection: View {
    @Binding var todos: [TodoItem]
    @Binding var showingDatePickerForIndex: Int?
    @Binding var reminderDate: Date
    @Binding var showConfirmation: Bool
    let reminderManager: ReminderManaging

    var body: some View {
        List {
            ForEach(todos.indices, id: \.self) { index in
                if !todos[index].isDone {
                    TodoRowView(
                        todo: todos[index],
                        isDatePickerVisible: showingDatePickerForIndex == index,
                        reminderDate: $reminderDate,
                        onToggle: {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                todos[index].isDone.toggle()
                                if todos[index].isDone {
                                    todos[index].reminderDate = nil
                                    reminderManager.remove(for: todos[index])
                                }
                            }
                        },
                        onBellTap: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                if showingDatePickerForIndex == index {
                                    showingDatePickerForIndex = nil
                                } else {
                                    if let existingDate = todos[index].reminderDate {
                                        reminderDate = existingDate
                                    }
                                    showingDatePickerForIndex = index
                                }
                            }
                        },
                        onDateSelected: {
                            withAnimation(.easeInOut) {
                                showConfirmation = true
                                showingDatePickerForIndex = nil
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation {
                                    showConfirmation = false
                                }
                            }
                        }
                    )
                    .listRowBackground(Color.clear)
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                todos[index].isDone.toggle()
                                if todos[index].isDone {
                                    todos[index].reminderDate = nil
                                    reminderManager.remove(for: todos[index])
                                }
                            }
                        } label: {
                            Label("Complete", systemImage: "checkmark")
                        }
                        .tint(.green)
                    }
                }
            }
        }
        .background(Color.clear)
        .scrollContentBackground(.hidden)
        .listStyle(.plain)
        .padding(.top)
    }
}
