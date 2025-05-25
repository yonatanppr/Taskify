import SwiftUI
import SwiftUICalendar


struct CalendarTodosView: View {
    @Binding var todos: [TodoItem]
    @State private var selectedDate: Date = Date()
    @StateObject private var calendarController = CalendarController()

    private var todosForSelectedDate: [TodoItem] {
        let selectedDay = Calendar.current.startOfDay(for: selectedDate)
        let matched = todos.filter {
            let todoDay = Calendar.current.startOfDay(for: $0.reminderDate ?? .distantPast)
            let isMatch = todoDay == selectedDay
            return isMatch
        }
        return matched
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

    // Helper to determine day text color for calendar cell
    private func dayTextColor(for date: YearMonthDay, isSelected: Bool) -> Color {
        guard let cellDate = date.date else { return .clear }
        if isSelected {
            return Color("TextColor")
        }

        let calendar = Calendar.current
        let cellComponents = calendar.dateComponents([.year, .month], from: cellDate)
        return (cellComponents.year == calendarController.yearMonth.year &&
                cellComponents.month == calendarController.yearMonth.month) ? .primary : .gray
    }

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                //Text("Reminders for \(selectedDate, style: .date)")
               //     .font(.system(size: 26, weight: .bold))
              //      .foregroundColor(Color("TextColor"))
              //      .padding(.bottom)
                
                VStack(spacing: 12) {
                    HStack {
                        Button(action: {
                            let current = calendarController.yearMonth
                            let previous = current.adding(months: -1)
                            calendarController.scrollTo(year: previous.year, month: previous.month, isAnimate: true)
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.accentGray)
                        }

                        Spacer()

                        Text("\(calendarController.yearMonth.monthLongString) \(String(calendarController.yearMonth.year))")
                            .font(.system(size: 25, weight: .bold))
                            .foregroundColor(Color("TextColor"))

                        Spacer()

                        Button(action: {
                            let current = calendarController.yearMonth
                            let next = current.adding(months: 1)
                            calendarController.scrollTo(year: next.year, month: next.month, isAnimate: true)
                        }) {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.accentGray)
                        }
                    }
                    .padding(.horizontal)

                    CalendarView(calendarController) { date in
                        GeometryReader { geometry in
                            ZStack {
                                if let dayDate = date.date {
                                    let isSelected = Calendar.current.isDate(dayDate, inSameDayAs: selectedDate)
                                    let isToday = date.isToday

                                    if isSelected {
                                        Circle()
                                            .fill(Color("SelectedCalendarDay"))
                                            .frame(width: geometry.size.width * 0.8, height: geometry.size.height * 0.8)
                                    } else if isToday {
                                        Circle()
                                            .stroke(Color("SelectedCalendarDay"), lineWidth: 1.5)
                                            .frame(width: geometry.size.width * 0.8, height: geometry.size.height * 0.8)
                                    }

                                    Text("\(date.day)")
                                        .font(.body)
                                        .fontWeight(isSelected ? .bold : .regular)
                                        .foregroundColor(dayTextColor(for: date, isSelected: isSelected))

                                    if datesWithReminders.contains(where: { Calendar.current.isDate($0, inSameDayAs: dayDate) }) {
                                        VStack {
                                            Spacer()
                                            Circle()
                                                .fill(isSelected ? Color("TextColor") : Color("SelectedCalendarDay"))
                                                .frame(width: 6, height: 6)
                                                .padding(.bottom, 4)
                                        }
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if let tapped = date.date {
                                    selectedDate = tapped
                                }
                            }
                        }
                    }
                    .frame(height: 320)
                    .padding(.horizontal)
                }
                .padding(.top)
                .background(Color("CalendarBackground"), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                .padding(.horizontal)

                VStack(spacing: 16) {

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
                        .padding()
                    } else {
                        VStack(spacing: 2) {
                            ForEach(todosForSelectedDate, id: \.id) { todo in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(todo.title)
                                        .font(.headline)
                                        .foregroundColor(Color("TextColor"))
                                    if let date = todo.reminderDate {
                                        Text(date, style: .time)
                                            .font(.caption)
                                            .foregroundColor(.secondaryText)
                                    }
                                }
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .cornerRadius(12)
                            }

                            Spacer(minLength: 8)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal)

                Spacer()
            }
            .onAppear {
                print("📆 SELECTED DATE: \(selectedDate)")
            }
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .top)
        }
        .background(Color.clear)
    }
}

// MARK: - YearMonth Extension for Adding Months
extension YearMonth {
    func adding(months: Int) -> YearMonth {
        let calendar = Calendar.current
        let date = calendar.date(from: DateComponents(year: self.year, month: self.month))!
        let newDate = calendar.date(byAdding: .month, value: months, to: date)!
        let components = calendar.dateComponents([.year, .month], from: newDate)
        return YearMonth(year: components.year!, month: components.month!)
    }
}

extension YearMonth {
    var monthLongString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "LLLL"
        let date = Calendar.current.date(from: DateComponents(year: year, month: month))!
        return formatter.string(from: date)
    }
}
