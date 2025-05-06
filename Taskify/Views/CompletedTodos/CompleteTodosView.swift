import SwiftUI
import Foundation

struct CompletedTodosView: View {
    @Binding var todos: [TodoItem]

    // Helper to find original index for un-completing
    private func originalIndex(for todoId: UUID) -> Int? {
        return todos.firstIndex(where: { $0.id == todoId })
    }

    var body: some View {
        ZStack {
            // CHANGE: Use appBackground
            Color.appBackground
                .ignoresSafeArea()

            // ADD: Title for the view
            VStack(alignment: .leading, spacing: 0) {
                Text("Completed Tasks")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primaryText)
                    .padding([.horizontal, .top])
                    .padding(.bottom, 10)


                if todos.filter({ $0.isDone }).isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "checkmark.circle.trianglebadge.exclamationmark")
                             .font(.system(size: 50))
                             .foregroundColor(.secondaryText.opacity(0.6))
                        Text("No tasks completed yet!")
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundColor(.secondaryText)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach($todos.filter { $0.wrappedValue.isDone }) { $todo in
                                HStack(spacing: 12) {
                                    // ADD: Checked circle icon
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 22, weight: .medium))
                                        .foregroundColor(.positiveGreen)
                                        .padding(.leading, 16)

                                    Text(todo.title)
                                        .font(.system(.headline, design: .rounded))
                                        // CHANGE: Use secondaryText for consistency
                                        .foregroundColor(.secondaryText)
                                        .strikethrough(true, color: .secondaryText)
                                        .padding(.vertical, 18)

                                    Spacer()
                                }
                                // CHANGE: Use componentBackground
                                .background(Color.componentBackground)
                                .cornerRadius(16)
                                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 3)
                                .padding(.horizontal)
                                .transition(.asymmetric(
                                    insertion: .scale(scale: 0.95, anchor: .center).combined(with: .opacity),
                                    removal: .opacity
                                ))
                                .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                    Button {
                                        if let index = originalIndex(for: todo.id) {
                                            withAnimation {
                                                todos[index].isDone = false
                                            }
                                        }
                                    } label: {
                                        Label("Mark as Incomplete", systemImage: "arrow.uturn.backward.circle")
                                    }
                                    .tint(.accentOrange)
                                }
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        withAnimation {
                                            todos.removeAll(where: { $0.id == todo.id })
                                        }
                                    } label: {
                                        Label("Delete", systemImage: "trash.fill")
                                    }
                                }
                            }
                        }
                        .padding(.top)
                    }
                }
            }
        }
    }
}
