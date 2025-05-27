import SwiftUI
import CoreHaptics

struct TodoRowView: View {
    var todo: TodoItem
    // `reminderDate` is bound from parent but not directly used in this View's logic to display
    // It's used by ActiveTodoListSection for the DatePicker logic.
    @Binding var reminderDate: Date
    var onToggle: () -> Void
    var onBellTap: () -> Void
    var onQuickTicToggle: () -> Void
    var namespace: Namespace.ID
    var showFullUI: Bool = true

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Main row: toggle, title, quick tic, bell
            HStack(alignment: .center, spacing: 0) {
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
                    .matchedGeometryEffect(id: "title-\(todo.id)", in: namespace)

                if showFullUI {
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
                } else {
                    Button(action: {}) {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .opacity(0)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .cornerRadius(10)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.leading, 6)
                    .disabled(true)
                }

                Spacer(minLength: 8)
                    .allowsHitTesting(false)

                if showFullUI {
                    // --- Bell Button ---
                    Button(action: {
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
                } else {
                    Button(action: {}) {
                        Image(systemName: todo.reminderDate != nil ? "bell.fill" : "bell")
                            .font(.system(size: 15, weight: .medium))
                            .opacity(0)
                            .frame(width: 36, height: 36, alignment: .center)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .contentShape(Rectangle())
                    .disabled(true)
                }
            }
            // Second row: right-aligned reminder date (if any)
            if let reminder = todo.reminderDate {
                HStack {
                    Spacer()
                    Text(formattedReminder(reminder))
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(reminder < Date() ? Color("OverdueBell") : Color("SelectedTodoAttribute"))
                        .padding(.trailing, 12)
                        .allowsHitTesting(false)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 2)
        .background(
            Color("TodoCard"), in: RoundedRectangle(cornerRadius: 18, style: .continuous)
        )
        .matchedGeometryEffect(id: "background-\(todo.id)", in: namespace)
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
