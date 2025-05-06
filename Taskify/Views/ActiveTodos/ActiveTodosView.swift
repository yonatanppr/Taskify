import SwiftUI
import Foundation

struct ActiveTodosView: View {
    @Binding var todos: [TodoItem]
    @Binding var newTodoText: String
    let reminderManager: ReminderManaging
    @Binding var showingDatePickerForIndex: Int?
    @Binding var reminderDate: Date
    @Binding var showConfirmation: Bool
    @State private var isLoading = false
    @State private var errorMessage: String? = nil

    private var backgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 0.93, green: 0.96, blue: 1.0),
                Color(red: 0.96, green: 0.90, blue: 1.0)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }


    var body: some View {
        ScrollViewReader { proxy in
            ZStack {
                backgroundGradient

                VStack(spacing: 16) {
                    VStack(spacing: 16) {
                        TodoInputBarView(newTodoText: $newTodoText) {
                            guard !newTodoText.isEmpty else { return }
                            isLoading = true
                            errorMessage = nil
                            parseTodosFromText(newTodoText) { items in
                                DispatchQueue.main.async {
                                    withAnimation(.spring()) {
                                        if items.isEmpty {
                                            errorMessage = "Failed to generate todos. Please try again."
                                            todos.append(TodoItem(title: "Mock Todo"))
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                                                withAnimation {
                                                    errorMessage = nil
                                                }
                                            }
                                        } else {
                                            for title in items {
                                                todos.append(TodoItem(title: title.trimmingCharacters(in: .whitespacesAndNewlines)))
                                            }
                                            newTodoText = ""
                                        }
                                        isLoading = false
                                    }
                                }
                            }
                        }

                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                                .scaleEffect(1.2)
                                .transition(.opacity)
                        }

                        if let message = errorMessage {
                            Text(message)
                                .font(.footnote)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                                .background(Color.red.opacity(0.8))
                                .clipShape(Capsule())
                                .transition(.opacity)
                        }

                        ActiveTodoListSection(
                            todos: $todos,
                            showingDatePickerForIndex: $showingDatePickerForIndex,
                            reminderDate: $reminderDate,
                            showConfirmation: $showConfirmation,
                            reminderManager: reminderManager
                        )

                        if showConfirmation {
                            ConfirmationToastView(message: "Reminder set!")
                                .transition(.move(edge: .top).combined(with: .opacity))
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                    .padding()
                    Spacer()
                }
                .onAppear {
                    withAnimation(.easeOut(duration: 0.5)) {}
                }
            }
        }
    }
}
