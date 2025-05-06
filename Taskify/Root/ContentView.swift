import SwiftUI
import Foundation

struct ContentView: View {
    @State private var todos: [TodoItem] = []
    @State private var newTodoText: String = ""
    @State private var showingDatePickerForIndex: Int? = nil
    @State private var reminderDate: Date = Date()
    @State private var showConfirmation: Bool = false
    @State private var isReady: Bool = false

    var body: some View {
        Group {
            if isReady {
                ZStack {
                    Color(red: 0.96, green: 0.96, blue: 0.94).ignoresSafeArea()

                    TabView {
                        ActiveTodosView(
                            todos: $todos,
                            newTodoText: $newTodoText,
                            reminderManager: ReminderService(),
                            showingDatePickerForIndex: $showingDatePickerForIndex,
                            reminderDate: $reminderDate,
                            showConfirmation: $showConfirmation
                        )
                        .tabItem {
                            Label("Todos", systemImage: "list.bullet")
                        }

                        CalendarTodosView(todos: $todos)
                            .tabItem {
                                Label("Calendar", systemImage: "calendar")
                            }

                        CompletedTodosView(todos: $todos)
                            .tabItem {
                                Label("Completed", systemImage: "checkmark.circle")
                            }
                    }

                    if let index = showingDatePickerForIndex {
                        ReminderOverlayView(
                            index: index,
                            todos: $todos,
                            reminderDate: $reminderDate,
                            showingDatePickerForIndex: $showingDatePickerForIndex,
                            showConfirmation: $showConfirmation,
                            reminderManager: ReminderService()
                        )
                        .zIndex(1000)
                    }
                }
            } else {
                LaunchScreenView()
            }
        }
        .onAppear {
            Task {
                await preloadApp()
                withAnimation(.easeOut(duration: 0.3)) {
                    isReady = true
                }
            }
        }
    }

    func preloadApp() async {
        let _ = UITextField() // Warm up UIKit text input system
        await Task.sleep(600 * 1_000_000) // Simulated load delay (600ms)
    }
}

#Preview {
    ContentView()
}

