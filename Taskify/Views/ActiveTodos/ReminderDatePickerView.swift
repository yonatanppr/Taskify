import SwiftUI

struct ReminderDatePickerView: View {
    @Binding var todo: TodoItem
    @Binding var reminderDate: Date
    var reminderManager: ReminderManaging
    var onDateSelected: (Bool) -> Void

    var body: some View {
        ZStack {
            Color.clear

            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 16) {
                    DatePicker(
                        "Select Date", 
                        selection: $reminderDate,
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .accentColor(.primaryAppBlue)
                    .id("datePicker-\(todo.id)")
                    .frame(maxWidth: .infinity)

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Select Time")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primaryText) 
                            .padding(.leading, 4)

                        DatePicker(
                            "", 
                            selection: $reminderDate,
                            displayedComponents: [.hourAndMinute]
                        )
                        .datePickerStyle(WheelDatePickerStyle())
                        .labelsHidden()
                        .accentColor(.primaryAppBlue) 
                        .frame(maxWidth: .infinity)
                    }
                }

                VStack(spacing: 12) { 
                    Button(action: {
                        todo.reminderDate = reminderDate
                        reminderManager.schedule(for: todo, at: reminderDate) { _ in
                            onDateSelected(false)
                        }
                    }) {
                        Text("Confirm")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.primaryAppBlue)
                            .cornerRadius(12)
                    }

                    Button(action: {
                        todo.reminderDate = nil
                        reminderManager.remove(for: todo)
                        onDateSelected(true)
                    }) {
                        Text("Remove reminder")
                            .fontWeight(.medium)
                            .foregroundColor(.destructiveRed)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.appBackground)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.secondaryText.opacity(0.3), lineWidth: 1)
                            )
                    }
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(24)
            .shadow(radius: 10)
            .frame(maxWidth: 360)
            .padding(.horizontal, 16)
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}
