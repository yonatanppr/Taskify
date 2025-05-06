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
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.easeInOut) {
                        showingDatePickerForIndex = nil
                    }
                }
                .transition(.opacity)

            VStack {
                Spacer(minLength: 60)

                VStack(spacing: 0) { 
                    HStack {
                        Spacer()
                        Button(action: {
                            withAnimation(.easeInOut) {
                                showingDatePickerForIndex = nil
                            }
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(Color.secondaryText.opacity(0.8))
                                .padding(8)
                                .contentShape(Rectangle()) // ensures full padding area is tappable
                        }
                    }
                    .padding([.top, .trailing], 12)

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
                        }
                    )
                    .padding(.bottom) 
                }
                .padding()
                .background(Color.white.opacity(0.9), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                .shadow(color: .black.opacity(0.15), radius: 15, y: 5)
                .frame(maxWidth: 340) 
                .fixedSize(horizontal: false, vertical: true) 
                .transition(.scale(scale: 0.9, anchor: .center).combined(with: .opacity).animation(.spring(response: 0.4, dampingFraction: 0.8)))

                Spacer(minLength: 60)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity) 
        .zIndex(1000)
    }
}
