import SwiftUI

struct CalendarTodosView: View {
    @Binding var todos: [TodoItem]
    @State private var selectedDate: Date = Date()

    private var todosForSelectedDate: [TodoItem] {
        todos.filter {
            guard let reminderDate = $0.reminderDate else { return false }
            return Calendar.current.isDate(reminderDate, inSameDayAs: selectedDate)
        }
    }

    private var datesWithReminders: [Date] {
        let dates = todos.compactMap { $0.reminderDate }
        return Array(Set(dates.map { Calendar.current.startOfDay(for: $0) })).sorted()
    }

    private func formattedDay(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }

    var body: some View {
        VStack(spacing: 16) {
            DatePicker(
                "Select a date",
                selection: $selectedDate,
                displayedComponents: [.date]
            )
            .datePickerStyle(.graphical)
            .padding()

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(datesWithReminders, id: \.self) { date in
                        VStack {
                            Text(formattedDay(date))
                                .font(.caption)
                                .foregroundColor(Calendar.current.isDate(date, inSameDayAs: selectedDate) ? .white : .blue)
                                .padding(6)
                                .background(Calendar.current.isDate(date, inSameDayAs: selectedDate) ? Color.blue : Color.clear)
                                .clipShape(Circle())

                            Circle()
                                .fill(Color.blue)
                                .frame(width: 6, height: 6)
                        }
                    }
                }
                .padding(.horizontal)
            }

            if todosForSelectedDate.isEmpty {
                Text("No reminders for selected day")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                List(todosForSelectedDate, id: \.id) { todo in
                    HStack {
                        Text(todo.title)
                        Spacer()
                        if let date = todo.reminderDate {
                            Text(date, style: .time)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
        }
        .padding()
    }
}
