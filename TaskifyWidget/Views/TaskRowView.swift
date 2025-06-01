import SwiftUI

struct TaskRow: View {
    let todo: TodoItem

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            Text(todo.title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color("TextColor"))
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
            if let reminder = todo.reminderDate {
                HStack(spacing: 2) {
                    Image(systemName: "clock")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color("ReminderAccent"))
                    Text(timeString(reminder))
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color("TextColor"))
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color("TodoCard"))
        )
    }

    private func timeString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}
