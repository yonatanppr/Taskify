import SwiftUI
import Foundation


struct ContentView: View {
    @State private var todos: [TodoItem] = []
    @State private var newTodoText: String = ""

    var body: some View {
        ZStack {
            Color(red: 0.96, green: 0.96, blue: 0.94).ignoresSafeArea() // pastel background

            TabView {
                ActiveTodosView(todos: $todos, newTodoText: $newTodoText)
                    .tabItem {
                        Label("Todos", systemImage: "list.bullet")
                    }

                CompletedTodosView(todos: $todos)
                    .tabItem {
                        Label("Completed", systemImage: "checkmark.circle")
                    }
            }
            .background(Color.clear)
        }
    }
}


#Preview {
    ContentView()
}
