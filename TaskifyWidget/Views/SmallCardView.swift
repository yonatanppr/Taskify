import SwiftUI

struct SmallCardView: View {
    let entry: TaskEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Today (\(entry.todos.count))")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Color("SubmitButton"))
            ForEach(entry.todos.prefix(4)) { todo in
                HStack {
                    Text(todo.title)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(Color("TextColor"))
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    if let reminder = todo.reminderDate {
                        Text(timeString(reminder))
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(Color("ReminderAccent"))
                            .frame(alignment: .trailing)
                    }
                }
            }
        }
        .padding(.top, 16)
        .padding(.horizontal, 12)
    }
    private func timeString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}
