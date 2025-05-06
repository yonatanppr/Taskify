import SwiftUI

struct ReminderDatePickerView: View {
    @Binding var todo: TodoItem
    @Binding var reminderDate: Date
    var reminderManager: ReminderManaging
    var onDateSelected: () -> Void

    var body: some View {
        ZStack {
            Color.clear
            VStack(spacing: 16) {
                DatePicker(
                    "Select Date",
                    selection: $reminderDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(GraphicalDatePickerStyle())

                DatePicker(
                    "Select Time",
                    selection: $reminderDate,
                    displayedComponents: [.hourAndMinute]
                )
                .datePickerStyle(WheelDatePickerStyle())

                Button(action: {
                    todo.reminderDate = reminderDate
                    reminderManager.schedule(for: todo, at: reminderDate) { _ in
                        onDateSelected()
                    }
                }) {
                    Text("Confirm")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }

                Button(action: {
                    todo.reminderDate = nil
                    reminderManager.remove(for: todo)
                    onDateSelected()
                }) {
                    Text("Remove reminder")
                        .foregroundColor(.blue)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(radius: 4)
            .padding(.horizontal)
            .padding(.bottom, 40)
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
        .ignoresSafeArea()
        .zIndex(1000)
    }
}
