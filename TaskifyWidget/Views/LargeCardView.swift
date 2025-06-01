import SwiftUI

struct LargeCardView: View {
    let entry: TaskEntry

    var body: some View {
        ZStack {
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 12) {
                        Text(formattedDay(entry.date))
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(Color("TextColor"))
                        Text(formattedMonth(entry.date))
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(Color("TextColor"))
                    }
                    Text("\(entry.todos.count) tasks")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(
                            Capsule().fill(Color("SubmitButton"))
                        )
                }
                .frame(minWidth: 80)
                .frame(maxHeight: .infinity)
                .multilineTextAlignment(.center)
                .padding(.vertical, 24)

                VStack(spacing: 12) {
                    if entry.todos.isEmpty {
                        Spacer()
                        Text("No tasks due today.")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(Color("TextColor"))
                            .multilineTextAlignment(.center)
                        Spacer()
                    } else {
                        ForEach(entry.todos.prefix(8)) { todo in
                            TaskRow(todo: todo)
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .padding(24)
        }
    }

    private func formattedDay(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("d")
        return formatter.string(from: date)
    }

    private func formattedMonth(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("MMM")
        return formatter.string(from: date)
    }
}
