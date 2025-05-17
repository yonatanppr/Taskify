import SwiftUI

struct ReminderDatePickerView: View {
    @Binding var todo: TodoItem
    @Binding var reminderDate: Date
    var reminderManager: ReminderManaging
    var onDateSelected: (Bool) -> Void
    var onReminderUpdated: (TodoItem) -> Void

    var body: some View {
        ZStack {
            // REMOVE: Color.clear - The ZStack will be sized by its content, and the background is applied to the VStack.
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 16) {
                    DatePicker(
                        "Select Date",
                        selection: $reminderDate,
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(GraphicalDatePickerStyle())
                    // CHANGE: Accent color to themeOrange
                    .accentColor(.accentGray)
                    .id("datePicker-\(todo.id)")
                    .frame(maxWidth: .infinity)
                    // ADD: ForegroundColor to make date picker text visible on glassy background
                    .foregroundColor(.primaryText)


                    VStack(alignment: .leading, spacing: 6) {
                        Text("Select Time")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                            .padding(.leading, 4)

                        DatePicker(
                            "",
                            selection: $reminderDate,
                            displayedComponents: [.hourAndMinute]
                        )
                        .datePickerStyle(WheelDatePickerStyle())
                        .labelsHidden()
                        // CHANGE: Accent color to themeOrange
                        .accentColor(.accentGray)
                        .frame(maxWidth: .infinity)
                        // ADD: ForegroundColor for wheel picker text
                        .colorScheme(.light) // To ensure wheel picker text is black on potentially light material
                    }
                }

                VStack(spacing: 12) {
                    Button(action: {
                        todo.reminderDate = reminderDate
                        reminderManager.schedule(for: todo, at: reminderDate) { updatedTodo in
                            self.todo = updatedTodo
                            onReminderUpdated(updatedTodo)
                            onDateSelected(false)
                        }
                    }) {
                        Text("Confirm")
                            .fontWeight(.semibold)
                            .foregroundColor(.primaryText)
                            .padding()
                            .frame(maxWidth: .infinity)
                            // CHANGE: Background to themeOrange
                            .background(Color.accentGray)
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
                            // CHANGE: Background to a subtle glassy style for secondary button
                            .background(
                                .clear
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            // REMOVE: Explicit .cornerRadius as it's handled by the material shape
                            // REMOVE: Overlay as it's not typical for glassy button
                    }
                }
            }
            .padding()
            // CHANGE: Background to glassy material
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            // REMOVE: .cornerRadius as it's handled by the material shape
            // REMOVE: .shadow
            .frame(maxWidth: 360)
            .padding(.horizontal, 16)
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}
