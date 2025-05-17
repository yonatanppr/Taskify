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

    @StateObject private var keyboardResponder = KeyboardResponder()
    @State private var currentDateText: String = ""

    enum TaskFilter: String, Identifiable {
        case all = "All"
        case upcoming = "Upcoming"
        case quickTics = "Quick Tics"
        //case completed = "Completed"

        var id: String { self.rawValue }

        static var allCases: [TaskFilter] {
            [.all, .upcoming, .quickTics]
        }
    }

    @State private var taskFilter: TaskFilter = .all
    @Namespace private var filterAnimation

    private let collapsedCardVisibleHeight: CGFloat = 140


    var body: some View {
        ZStack {
            GeometryReader { geometryOfActiveTodosView in
                Group {
                    ZStack(alignment: .bottom) {
                        VStack(spacing: 24) {
                            HStack(spacing: 12) {
                                Button(action: {}) {
                                    Image(systemName: "person.circle")
                                        .font(.system(size: 22, weight: .thin))
                                        .padding(12)
                                        .foregroundColor(.white)
                                        .background(
                                            ZStack {
                                                Color.clear
                                                    .background(.ultraThinMaterial)
                                                Color.gray.opacity(0.1)
                                            }
                                        )
                                        .clipShape(Circle())
                                }

                                Button(action: {}) {
                                    Image(systemName: "gearshape")
                                        .font(.system(size: 22, weight: .thin))
                                        .padding(12)
                                        .foregroundColor(.white)
                                        .background(
                                            ZStack {
                                                Color.clear
                                                    .background(.ultraThinMaterial)
                                                Color.gray.opacity(0.1)
                                            }
                                        )
                                        .clipShape(Circle())
                                }

                                Spacer()
                                
                                Text(currentDateText)
                                    .font(.system(size: 53, weight: .bold, design: .rounded))
                                    .foregroundColor(.primaryText)
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 35)
                            .onAppear {
                                let formatter = DateFormatter()
                                formatter.dateFormat = "dd MMMM"
                                currentDateText = formatter.string(from: Date())
                            }
                            HStack(spacing: 0) {
                                ForEach(TaskFilter.allCases) { filter in
                                    Button(action: {
                                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                            taskFilter = filter
                                        }
                                    }) {
                                        ZStack {
                                            if taskFilter == filter {
                                                RoundedRectangle(cornerRadius: 20)
                                                    .fill(Color.accentGray.opacity(0.6))
                                                    .matchedGeometryEffect(id: "filterBackground", in: filterAnimation)
                                                    .allowsHitTesting(false)
                                            }

                                            Text(filter.rawValue)
                                                .font(.footnote)
                                                .fontWeight(.medium)
                                                .foregroundColor(taskFilter == filter ? .primaryText : .primaryText)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 32)
                                    }
                                    .contentShape(Rectangle())
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                            .padding(.horizontal, 20)

                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .accentGray))
                                    .scaleEffect(1.4)
                                    .transition(.scale.animation(.spring(response: 0.3, dampingFraction: 0.6)))
                            }

                            ActiveTodoListSection(
                                todos: $todos,
                                taskFilter: taskFilter,
                                showingDatePickerForIndex: $showingDatePickerForIndex,
                                reminderDate: $reminderDate,
                                showConfirmation: $showConfirmation,
                                reminderManager: reminderManager
                            )
                            .transition(.asymmetric(insertion: .move(edge: .bottom).combined(with: .opacity),
                                                    removal: .opacity))
                            .animation(.spring(response: 0.4, dampingFraction: 0.75), value: taskFilter)
                        }
                        .padding(.horizontal, 16)
                        .frame(maxWidth: .infinity)
                        .zIndex(0)


                        DraggableInputCardView(
                            newTodoText: $newTodoText,
                            onSubmit: handleNewTodoSubmission,
                            errorMessage: $errorMessage,
                            todos: $todos
                        )
                        .zIndex(1)

                        if showConfirmation {
                            VStack {
                                Spacer()
                                ConfirmationToastView(message: "Reminder set!")
                                    .padding(.bottom, collapsedCardVisibleHeight + 10 + keyboardResponder.currentHeight)
                                    .transition(.move(edge: .bottom).animation(.spring(response: 0.4, dampingFraction: 0.7)))
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .zIndex(2)
                            .allowsHitTesting(false)
                        }
                    }
                    .animation(nil, value: showingDatePickerForIndex)
                }
                .animation(.spring(response: 0.35, dampingFraction: 0.85, blendDuration: 0), value: keyboardResponder.currentHeight)
            }
            .background(Color.clear)
            .ignoresSafeArea(.keyboard, edges: .bottom)

            if let index = showingDatePickerForIndex {
                ReminderOverlayView(
                    index: index,
                    todos: $todos,
                    reminderDate: $reminderDate,
                    showingDatePickerForIndex: $showingDatePickerForIndex,
                    showConfirmation: $showConfirmation,
                    reminderManager: reminderManager
                )
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
