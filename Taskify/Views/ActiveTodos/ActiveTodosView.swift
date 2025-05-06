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

    enum TaskFilter: String, CaseIterable, Identifiable {
        case all = "All"
        case upcoming = "Upcoming"
        case completed = "Completed"

        var id: String { self.rawValue }
    }

    @State private var taskFilter: TaskFilter = .all
    @Namespace private var filterAnimation


    var body: some View {
        ZStack(alignment: .top) {
            Color.appBackground
                .ignoresSafeArea()

            VStack(spacing: 24) {
                // Input bar
                VStack(spacing: 12) {
                    TodoInputBarView(newTodoText: $newTodoText) {
                        handleNewTodoSubmission()
                    }

                    if let message = errorMessage {
                        Text(message)
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.destructiveRed.opacity(0.9))
                            .clipShape(Capsule())
                            .transition(.scale(scale: 0.9, anchor: .top).animation(.spring(response: 0.3, dampingFraction: 0.6)))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 40)

                HStack(spacing: 0) {
                    ForEach(TaskFilter.allCases) { filter in
                        Button(action: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                taskFilter = filter
                            }
                        }) {
                            ZStack {
                                if taskFilter == filter {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.primaryAppBlue)
                                        .matchedGeometryEffect(id: "filterBackground", in: filterAnimation)
                                        .allowsHitTesting(false)
                                }

                                Text(filter.rawValue)
                                    .font(.footnote)
                                    .fontWeight(.medium)
                                    .foregroundColor(taskFilter == filter ? .white : .primaryAppBlue)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 32)
                        }
                        .contentShape(Rectangle())
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .background(Color.primaryAppBlue.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.horizontal, 20)
                .zIndex(1)

                // Loading Indicator
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .primaryAppBlue))
                        .scaleEffect(1.4)
                        .transition(.scale.animation(.spring(response: 0.3, dampingFraction: 0.6)))
                }

                // Todo List
                ActiveTodoListSection(
                    todos: $todos,
                    taskFilter: taskFilter,
                    showingDatePickerForIndex: $showingDatePickerForIndex,
                    reminderDate: $reminderDate,
                    showConfirmation: $showConfirmation,
                    reminderManager: reminderManager
                )
                .padding(.horizontal, 16)
                .zIndex(0)

                // Confirmation Toast
                if showConfirmation {
                    ConfirmationToastView(message: "Reminder set!")
                        .transition(.move(edge: .top).animation(.spring(response: 0.4, dampingFraction: 0.7)))
                }

                Spacer(minLength: 24)
            }
        }
    }

    private func handleNewTodoSubmission() {
        TodoGenerationHandler.handleNewTodoSubmission(
            text: newTodoText,
            todos: $todos,
            isLoading: $isLoading,
            errorMessage: $errorMessage,
            reminderManager: reminderManager
        ) {
            newTodoText = ""
        }
    }
}
