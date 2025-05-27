import SwiftUI
import Foundation

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()
    
    var body: some View {
        GeometryReader { geometry in
            Group {
                if viewModel.isReady {
                    ZStack {
                        Color.clear
                            .contentShape(Rectangle())
                            .onTapGesture {
                                viewModel.newTodoText = ""
                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                            }
                        ZStack {
                            KeyboardPreloadView()
                            ActiveTodosView(
                                todos: $viewModel.todos,
                                newTodoText: $viewModel.newTodoText,
                                reminderManager: ReminderService(),
                                showingDatePickerForIndex: $viewModel.showingDatePickerForIndex,
                                reminderDate: $viewModel.reminderDate
                            )
                            .zIndex(0)
                            if let index = viewModel.showingDatePickerForIndex {
                                // your existing date picker logic
                            }
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
