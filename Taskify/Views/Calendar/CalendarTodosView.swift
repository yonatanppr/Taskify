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
        GeometryReader { geometry in
            VStack(spacing: 0) {
                DatePicker(
                    "",
                    selection: $selectedDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                .accentColor(.primaryAppBlue)
                .frame(maxHeight: 380)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.componentBackground)
                        .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 4)
                )
                .padding(.horizontal)
                .padding(.top, 20)

                VStack(spacing: 16) {
                    Text("Reminders for \(selectedDate, style: .date)")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.primaryAppBlue)
                        .padding(.top)

                    if todosForSelectedDate.isEmpty {
                        VStack {
                            Spacer(minLength: 20)
                            Image(systemName: "calendar.badge.exclamationmark")
                                .font(.system(size: 40))
                                .foregroundColor(.secondaryText.opacity(0.5))
                            Text("No reminders for this day.")
                                .foregroundColor(.secondaryText)
                                .font(.headline)
                            Spacer(minLength: 20)
                        }
                        .frame(maxHeight: .infinity)
                        .padding()
                    } else {
                        List {
                            ForEach(todosForSelectedDate, id: \.id) { todo in
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(todo.title)
                                            .font(.headline)
                                            .foregroundColor(.primaryText)
                                        if let date = todo.reminderDate {
                                            Text(date, style: .time)
                                                .font(.caption)
                                                .foregroundColor(.secondaryText)
                                        }
                                    }
                                    Spacer()
                                    if let date = todo.reminderDate, date > Date() {
                                        Circle()
                                            .fill(Color.accentOrange)
                                            .frame(width: 8, height: 8)
                                    }
                                }
                                .padding(.vertical, 8)
                            }
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                    }
                }
                .padding(.horizontal)

                Spacer()
            }
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .top)
            .background(Color.appBackground.ignoresSafeArea())
        }
    }
}
