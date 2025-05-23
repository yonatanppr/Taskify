import SwiftUI

struct TodoRowView: View {
    var todo: TodoItem
    // `reminderDate` is bound from parent but not directly used in this View's logic to display
    // It's used by ActiveTodoListSection for the DatePicker logic.
    @Binding var reminderDate: Date
    var onToggle: () -> Void
    var onBellTap: () -> Void
    var onQuickTicToggle: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            // Main row: toggle, title, quick tic, bell
            HStack(alignment: .center, spacing: 0) {
                // --- Toggle Button ---
                Button(action: {
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                    onToggle()
                }) {
                    Image(systemName: todo.isDone ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(todo.isDone ? .positiveGreen : .primaryText)
                        .frame(width: 44, height: 44, alignment: .center)
                }
                .buttonStyle(PlainButtonStyle())
                .contentShape(Rectangle())

                Text(todo.title)
                    .font(.system(size: 19, weight: .regular, design: .rounded))
                    .foregroundColor(todo.isDone ? .secondaryText : .primaryText)
                    .strikethrough(todo.isDone, color: .secondaryText)
                    .padding(.leading, 12)
                    .padding(.vertical, 12)
                    .allowsHitTesting(false)

                Button(action: {
                    onQuickTicToggle()
                }) {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(todo.isQuickTic ? .quickTicYellow : .primaryText.opacity(0.7))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .cornerRadius(10)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.leading, 6)

                Spacer(minLength: 8)
                    .allowsHitTesting(false)

                // --- Bell Button ---
                Button(action: {
                    onBellTap()
                }) {
                    Image(systemName: todo.reminderDate != nil ? "bell.fill" : "bell")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor({
                            if let date = todo.reminderDate {
                                return date < Date() ? .destructiveRed : .quickTicYellow
                            } else {
                                return .primaryText.opacity(0.7)
                            }
                        }())
                        .frame(width: 44, height: 44, alignment: .center)
                }
                .buttonStyle(PlainButtonStyle())
                .contentShape(Rectangle())
            }
            // Second row: right-aligned reminder date (if any)
            if let reminder = todo.reminderDate {
                HStack {
                    Spacer()
                    Text(formattedReminder(reminder))
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(reminder < Date() ? .destructiveRed : .quickTicYellow)
                        .padding(.trailing, 12)
                        .allowsHitTesting(false)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
        .background(
            .ultraThinMaterial.opacity(0.5), in: RoundedRectangle(cornerRadius: 20, style: .continuous)
        )
        .padding(.horizontal, 8)
        .id(todo.id)
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
