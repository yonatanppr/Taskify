import SwiftUI
import Foundation

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()
    
    var body: some View {
        GeometryReader { geometry in
            Group {
                if viewModel.isReady {
                    ZStack {
                        ZStack {
                            KeyboardPreloadView()
                            ActiveTodosView(
                                todos: $viewModel.todos,
                                newTodoText: $viewModel.newTodoText,
                                reminderManager: ReminderService(),
                                // removed: showingDatePickerForIndex
                                reminderDate: $viewModel.reminderDate
                            )
                            .zIndex(0)
                        }
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .ignoresSafeArea(.keyboard)
                } else {
                    LaunchScreenView()
                }
            }
            .background(
                Color("AppBackground")
            )
        }
        .onAppear {
            Task {
                await viewModel.preloadApp()
            }
        }
        .onChange(of: viewModel.todos) {
            SharedStorage.saveTodos(viewModel.todos)
        }
    }
}

#Preview {
    ContentView()
}
