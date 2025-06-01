import Foundation
import SwiftUI

struct WidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: TaskEntry

    var body: some View {
        Group {
            switch family {
            case .systemSmall:
                smallCardView
            case .systemLarge:
                largeCardView
            default:
                mainCardView
            }
        }
    }

    private var smallCardView: some View {
        VStack(spacing: 8) {
            Text("\(formattedDay(entry.date)) \(formattedMonth(entry.date))")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(Color("TextColor"))
            if let firstTodo = entry.todos.first {
                Text(firstTodo.title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color("TextColor"))
                    .lineLimit(1)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color("TodoCard"))
                    )
            } else {
                Text("No tasks")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color("TextColor"))
            }
        }
        .padding(16)
    }

    private var largeCardView: some View {
        ZStack {
            HStack(spacing: 20) {
                // Left side: date and count with larger fonts and padding
                VStack(spacing: 12) {
                    Text(formattedDay(entry.date))
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(Color("TextColor"))
                    Text(formattedMonth(entry.date))
                        .font(.system(size: 28, weight: .medium))
                        .foregroundColor(Color("TextColor"))
                    Text("\(entry.todos.count)")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(Color("SubmitButton"))
                        )
                }
                .frame(minWidth: 80)
                .frame(maxHeight: .infinity)
                .multilineTextAlignment(.center)
                .padding(.vertical, 24)

                // Right side: todos list or no tasks message with up to 8 todos
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
                            taskRow(todo: todo)
                        }
                        Spacer(minLength: 12)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .padding(24)
        }
      //  .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private var mainCardView: some View {
        ZStack {
            HStack(spacing: 20) {
                // Left side: date and count
                VStack(spacing: 8) {
                    HStack(spacing: 4) {
                        Text(formattedDay(entry.date))
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(Color("TextColor"))
                        Text(formattedMonth(entry.date))
                            .font(.system(size: 32, weight: .medium))
                            .foregroundColor(Color("TextColor"))
                    }
                    Text("\(entry.todos.count) tasks")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color("SubmitButton"))
                        )
                }
                .frame(minWidth: 60)
                .frame(maxHeight: .infinity)
                .multilineTextAlignment(.center)
                .padding(.vertical, 18)

                // Right side: todos list or no tasks message, vertically centered
                GeometryReader { geo in
                    VStack {
                        Spacer()
                        VStack(spacing: 10) {
                            if entry.todos.isEmpty {
                                Text("No tasks due today.")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(Color("FilterBar + Menu/FilterText"))
                                    .multilineTextAlignment(.center)
                            } else {
                                ForEach(entry.todos.prefix(3)) { todo in
                                    taskRow(todo: todo)
                                }
                                Spacer(minLength: 8)
                            }
                        }
                        Spacer()
                    }
                    .frame(width: geo.size.width, height: geo.size.height)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .padding(18)
        }
    }

    private func taskRow(todo: TodoItem) -> some View {
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

    // MARK: - Helpers
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
    private func timeString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}
