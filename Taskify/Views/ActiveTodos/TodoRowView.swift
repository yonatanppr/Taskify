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
        HStack(alignment: .center, spacing: 0) { // Use spacing 0 and control with padding
            // --- Toggle Button ---
            Button(action: {
                onToggle()
            }) {
                Image(systemName: todo.isDone ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(todo.isDone ? .positiveGreen : .primaryText) // Keep positiveGreen for checkmark, white for circle
                    .frame(width: 44, height: 44, alignment: .center) // Explicit frame for tap target
            }
            .buttonStyle(PlainButtonStyle()) // Essential for List row buttons
            .contentShape(Rectangle())

            // --- Title Text (Non-Interactive) ---
            Text(todo.title)
                .font(.system(size: 18, weight: .regular, design: .rounded))
                .foregroundColor(todo.isDone ? .secondaryText : .primaryText) // White text, slightly faded if done
                .strikethrough(todo.isDone, color: .secondaryText)
                .padding(.leading, 12) // Space from toggle button
                .padding(.vertical, 12) // Maintain row height
                .allowsHitTesting(false) // Prevent text from capturing taps

            Button(action: {
                onQuickTicToggle()
            }) {
                Image(systemName: "bolt.fill")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(todo.isQuickTic ? .quickTicYellow : .primaryText.opacity(0.7)) // quickTicYellow or slightly visible white
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    //.background(todo.isQuickTic ? .quickTicYellow.opacity(0.25) : Color.clear)
                    .cornerRadius(10)
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.leading, 6)

            Spacer(minLength: 8) // Ensure some separation
                .allowsHitTesting(false) // Prevent spacer from capturing taps

            // --- Bell Button ---
            Button(action: {
                onBellTap()
            }) {
                Image(systemName: todo.reminderDate != nil ? "bell.fill" : "bell")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor({
                        if let date = todo.reminderDate {
                            // set bell to different color if task is overdue
                            return date < Date() ? .destructiveRed : .quickTicYellow
                        } else {
                            return .primaryText.opacity(0.7)
                        }
                    }())
                    .frame(width: 44, height: 44, alignment: .center) // Explicit frame for tap target
            }
            .buttonStyle(PlainButtonStyle()) // Essential for List row buttons
            .contentShape(Rectangle())
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
        .background(
            .ultraThinMaterial.opacity(0.5), in: RoundedRectangle(cornerRadius: 20, style: .continuous)
        )
        .padding(.horizontal, 8)
        .id(todo.id)
        // IMPORTANT: No .onTapGesture or .highPriorityGesture on this HStack.
        // Let the List and the Buttons with PlainButtonStyle handle taps.
        // If a transition effect is desired, it can be added back:
        // .transition(.asymmetric(
        //     insertion: .scale(scale: 0.95, anchor: .center).combined(with: .opacity),
        //     removal: .opacity
        // ))
    }
}
