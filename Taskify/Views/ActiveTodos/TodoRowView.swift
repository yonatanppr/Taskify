import SwiftUI

struct TodoRowView: View {
    var todo: TodoItem
    // `reminderDate` is bound from parent but not directly used in this View's logic to display
    // It's used by ActiveTodoListSection for the DatePicker logic.
    @Binding var reminderDate: Date
    var onToggle: () -> Void
    var onBellTap: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 0) { // Use spacing 0 and control with padding
            // --- Toggle Button ---
            Button(action: {
                onToggle()
            }) {
                Image(systemName: todo.isDone ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(todo.isDone ? .positiveGreen : .secondaryText.opacity(0.7))
                    .frame(width: 44, height: 44, alignment: .center) // Explicit frame for tap target
            }
            .buttonStyle(PlainButtonStyle()) // Essential for List row buttons
            .contentShape(Rectangle())

            // --- Title Text (Non-Interactive) ---
            Text(todo.title)
                .font(.system(.headline, design: .rounded))
                .foregroundColor(todo.isDone ? .secondaryText : .primaryText)
                .strikethrough(todo.isDone, color: .secondaryText)
                .padding(.leading, 12) // Space from toggle button
                .padding(.vertical, 18) // Maintain row height
                .allowsHitTesting(false) // Prevent text from capturing taps

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
                            return date < Date() ? Color.reminderOverdue : Color.reminderUpcoming
                        } else {
                            return .primaryAppBlue.opacity(0.8)
                        }
                    }())
                    .frame(width: 44, height: 44, alignment: .center) // Explicit frame for tap target
            }
            .buttonStyle(PlainButtonStyle()) // Essential for List row buttons
            .contentShape(Rectangle())
        }
        .padding(.horizontal)
        .padding(.vertical, 6)
        .background(Color.componentBackground)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 3)
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
