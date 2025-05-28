import SwiftUI
import CoreHaptics

struct TodoRowView: View {
    var todo: TodoItem
    @Binding var reminderDate: Date
    var onToggle: () -> Void
    var onBellTap: () -> Void
    var onQuickTicToggle: () -> Void

    var onUpdate: (TodoItem) -> Void
    var onRemoveReminder: (TodoItem) -> Void
    let reminderManager: ReminderManaging

    @State private var isExpanded: Bool = false
    @State private var didCancel: Bool = false
    // Removed cardWidth, no longer needed

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Main row
            HStack(spacing: 0) {
                // --- Toggle Button ---
                Button(action: {
                    if CHHapticEngine.capabilitiesForHardware().supportsHaptics {
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.prepare()
                        generator.impactOccurred()
                    }
                    onToggle()
                }) {
                    Image(systemName: todo.isDone ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(todo.isDone ? .positiveGreen : Color("TodoText"))
                        .frame(width: 36, height: 36, alignment: .center)
                }
                .buttonStyle(PlainButtonStyle())
                .contentShape(Rectangle())

                Text(todo.title)
                    .font(.system(size: 17, weight: .regular, design: .rounded))
                    .foregroundColor(todo.isDone ? .secondaryText : Color("TodoText"))
                    .strikethrough(todo.isDone, color: .secondaryText)
                    .padding(.leading, 12)
                    .padding(.vertical, 8)
                    .allowsHitTesting(false)

                Button(action: {
                    onQuickTicToggle()
                }) {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(todo.isQuickTic ? Color("SelectedTodoAttribute") : Color("UnselectedTodoAttribute"))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .cornerRadius(10)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.leading, 6)

                Spacer(minLength: 8)
                    .allowsHitTesting(false)

                // --- Bell Button ---
                Button(action: {
                    isExpanded.toggle()
                    onBellTap()
                }) {
                    Image(systemName: todo.reminderDate != nil ? "bell.fill" : "bell")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor({
                            if let date = todo.reminderDate {
                                return date < Date() ? Color("OverdueBell") : Color("SelectedTodoAttribute")
                            } else {
                                return Color("UnselectedTodoAttribute")
                            }
                        }())
                        .frame(width: 36, height: 36, alignment: .center)
                }
                .buttonStyle(PlainButtonStyle())
                .contentShape(Rectangle())
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)

            // Reminder text row
            if let reminder = todo.reminderDate {
                HStack {
                    Spacer()
                    Text(formattedReminder(reminder))
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(reminder < Date() ? Color("OverdueBell") : Color("SelectedTodoAttribute"))
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 8)
            }

            // Expanded picker section
            if isExpanded {
                VStack(spacing: 12) {
                    DatePicker("", selection: $reminderDate, displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                        .frame(height: 150)

                    HStack(spacing: 20) {
                        if todo.reminderDate != nil {
                            Button("Remove") {
                                reminderManager.remove(for: todo)
                                var updated = todo
                                updated.reminderDate = nil
                                updated.reminderID = nil
                                onRemoveReminder(updated)
                                isExpanded = false
                            }
                            .foregroundColor(.red)
                        } else {
                            Button("Cancel") {
                                isExpanded = false
                            }
                            .foregroundColor(.gray)
                        }

                        Spacer()

                        Button("Set") {
                            if todo.reminderDate != reminderDate {
                                var updated = todo
                                updated.reminderDate = reminderDate
                                reminderManager.schedule(for: updated, at: reminderDate) { newTodo in
                                    onUpdate(newTodo)
                                    isExpanded = false
                                }
                            } else {
                                isExpanded = false
                            }
                        }
                        .foregroundColor(.blue)
                    }
                    .padding(.horizontal, 12)
                }
                .padding(.bottom, 8)
            }
        }
        .frame(maxWidth: .infinity)
        .background(
            Color("TodoCard")
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        )
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
        .animation(.easeInOut(duration: 0.25), value: isExpanded)
    }

    private func formattedReminder(_ date: Date) -> String {
        let timeString = date.formatted(date: .omitted, time: .shortened)
        if Calendar.current.isDateInToday(date) {
            return "today \(timeString)"
        } else if Calendar.current.isDateInTomorrow(date) {
            return "tomorrow \(timeString)"
        } else {
            let day = Calendar.current.component(.day, from: date)
            let month = date.formatted(.dateTime.month(.abbreviated))
            return "\(day) \(month) \(timeString)"
        }
    }
}
