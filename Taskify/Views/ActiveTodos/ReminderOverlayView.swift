import SwiftUI

struct ReminderOverlayView: View {
    let index: Int
    @Binding var todos: [TodoItem]
    @Binding var reminderDate: Date
    @Binding var showingDatePickerForIndex: Int?
    @Binding var showConfirmation: Bool
    let reminderManager: ReminderManaging

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 16) {
                ReminderDatePickerView(
                    todo: $todos[index],
                    reminderDate: $reminderDate,
                    reminderManager: reminderManager,
                    onDateSelected: { didCancel in
                        withAnimation(.easeInOut) {
                            showingDatePickerForIndex = nil
                        }
                        if !didCancel {
                            withAnimation(.easeInOut) {
                                showConfirmation = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation {
                                    showConfirmation = false
                                }
                            }
                        }
                    },
                    onReminderUpdated: { updatedTodo in
                        todos[index] = updatedTodo
                    }
                )
                .padding(.top, 16)
            }
            .padding()
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .shadow(color: .shadowGray, radius: 15, y: 5)
            .frame(width: 340)
            .fixedSize(horizontal: false, vertical: true)

            Button(action: {
                withAnimation(.easeInOut) {
                    showingDatePickerForIndex = nil
                }
            }) {
                Image(systemName: "xmark")
                    .foregroundColor(.gray)
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .padding(8)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
                    .padding([.top, .trailing], 12)
            }
        }
        .position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2.2)
    }
}
