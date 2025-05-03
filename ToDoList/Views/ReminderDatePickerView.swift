import SwiftUI

struct ReminderDatePickerView: View {
    var title: String
    @Binding var reminderDate: Date
    var onDateSelected: () -> Void

    var body: some View {
        DatePicker(
            "Reminder Time",
            selection: $reminderDate,
            displayedComponents: [.date, .hourAndMinute]
        )
        .datePickerStyle(GraphicalDatePickerStyle())
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 4)
        .padding(.horizontal)
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .onChange(of: reminderDate) { oldValue, newValue in
            ReminderService.scheduleReminder(for: title, at: newValue)
            onDateSelected()
        }
    }
}
