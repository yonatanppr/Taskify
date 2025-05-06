import SwiftUI

struct TodoRowView: View {
    var todo: TodoItem
    var isDatePickerVisible: Bool
    @Binding var reminderDate: Date
    var onToggle: () -> Void
    var onBellTap: () -> Void
    var onDateSelected: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(todo.title)
                    .font(.system(.headline, design: .rounded))
                    .padding(.vertical, 14)
                    .padding(.leading, 18)
                    .foregroundColor(.primary)
                    .contentShape(Rectangle())

                Spacer()

                Button(action: onBellTap) {
                    Image(systemName: "bell")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(todo.reminderDate != nil ? Color.orange : Color.blue.opacity(0.7))
                }
                .padding(.trailing, 18)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(red: 0.96, green: 0.98, blue: 1.0))
        )
        .padding(.horizontal)
        .padding(.vertical, 4)
        .shadow(color: Color.black.opacity(0.03), radius: 3, x: 0, y: 2)
        .transition(.asymmetric(
            insertion: .scale.combined(with: .opacity),
            removal: .opacity
        ))
        .id(todo.id)
    }
}
