import SwiftUI

struct ReminderOverlayView: View {
    let index: Int
    @Binding var todos: [TodoItem]
    @Binding var reminderDate: Date
    @Binding var showingDatePickerForIndex: Int?
    @Binding var showConfirmation: Bool
    let reminderManager: ReminderManaging

    var body: some View {
        ZStack {
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation {
                        showingDatePickerForIndex = nil
                    }
                }

            ReminderDatePickerView(
                todo: $todos[index],
                reminderDate: $reminderDate,
                reminderManager: reminderManager,
                onDateSelected: {
                    withAnimation(.easeInOut) {
                        showConfirmation = true
                        showingDatePickerForIndex = nil
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            showConfirmation = false
                        }
                    }
                }
            )
            .transition(.move(edge: .bottom).combined(with: .opacity))
            .zIndex(1)
        }
    }
}
