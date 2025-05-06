import SwiftUI
import Foundation

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()
    
    var body: some View {
        Group {
            if viewModel.isReady {
                ZStack {
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.94, green: 0.97, blue: 1.0),
                            Color(red: 0.98, green: 0.94, blue: 1.0)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()

                    ZStack(alignment: .bottomTrailing) {
                        Group {
                            if viewModel.isShowingCalendarView {
                                AnyView(CalendarTodosView(todos: $viewModel.todos))
                            } else {
                                AnyView(ActiveTodosView(
                                    todos: $viewModel.todos,
                                    newTodoText: $viewModel.newTodoText,
                                    reminderManager: ReminderService(),
                                    showingDatePickerForIndex: $viewModel.showingDatePickerForIndex,
                                    reminderDate: $viewModel.reminderDate,
                                    showConfirmation: $viewModel.showConfirmation
                                ))
                            }
                        }
                        .transition(.move(edge: viewModel.isShowingCalendarView ? .trailing : .leading))
                        .zIndex(0)
                        .animation(.easeInOut(duration: 0.35), value: viewModel.isShowingCalendarView)

                        if let index = viewModel.showingDatePickerForIndex {
                            ReminderOverlayView(
                                index: index,
                                todos: $viewModel.todos,
                                reminderDate: $viewModel.reminderDate,
                                showingDatePickerForIndex: $viewModel.showingDatePickerForIndex,
                                showConfirmation: $viewModel.showConfirmation,
                                reminderManager: ReminderService()
                            )
                            .transition(.scale(scale: 0.95).combined(with: .opacity))
                            .zIndex(1000)
                        }

                        ViewToggleButton(
                            isShowingCalendarView: $viewModel.isShowingCalendarView,
                            showViewSelectionDialog: $viewModel.showViewSelectionDialog
                        )
                    }
                }
            } else {
                LaunchScreenView()
            }
        }
        .onAppear {
            Task {
                await viewModel.preloadApp()
            }
        }
        .onChange(of: viewModel.todos) {
            TodoStorage.save(viewModel.todos)
        }
    }
}

#Preview {
    ContentView()
}
