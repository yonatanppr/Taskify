import SwiftUI
import Foundation


struct CompletedTodosView: View {
    @Binding var todos: [TodoItem]

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()

            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(todos.indices.filter { todos[$0].isDone }, id: \.self) { index in
                        let todo = todos[index]
                        HStack {
                            Text(todo.title)
                                .font(.system(.body, design: .rounded))
                                .foregroundColor(.gray)
                                .strikethrough()
                                .padding(.vertical, 12)
                                .padding(.horizontal)
                            Spacer()
                        }
                        .background(Color.white)
                        .cornerRadius(14)
                        .shadow(color: Color.black.opacity(0.04), radius: 3, x: 0, y: 2)
                        .padding(.horizontal)
                        .transition(.asymmetric(insertion: .scale.combined(with: .opacity),
                                                removal: .opacity))
                    }
                }
                .padding(.top)
                .onAppear {
                    withAnimation(.easeOut(duration: 0.5)) {}
                }
            }
        }
    }
}
