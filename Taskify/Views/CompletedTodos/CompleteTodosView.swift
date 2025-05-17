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
            // REMOVE: Color.appBackground.ignoresSafeArea() - Let ContentView gradient show through
            VStack(alignment: .leading, spacing: 0) {
                Text("Completed Tasks")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primaryText) // Already white
                    .padding([.horizontal, .top])
                    .padding(.bottom, 10)


                if todos.filter({ $0.isDone }).isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "checkmark.circle.trianglebadge.exclamationmark")
                             .font(.system(size: 50))
                             .foregroundColor(.secondaryText) // Semi-transparent white
                        Text("No tasks completed yet!")
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundColor(.secondaryText) // Semi-transparent white
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
                                        .foregroundColor(.positiveGreen) // Stays green
                                        .padding(.leading, 16)

                                    Text(todo.title)
                                        .font(.system(.headline, design: .rounded))
                                        // CHANGE: Use secondaryText for consistency
                                        .foregroundColor(.secondaryText) // Semi-transparent white
                                        .strikethrough(true, color: .secondaryText)
                                        .padding(.vertical, 18)

                                    Spacer()
                                }
                                // CHANGE: Background to glassy style
                                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                                // REMOVE: .cornerRadius as it's handled by material shape
                                // REMOVE: .shadow
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
                                    // CHANGE: Tint to themeOrange
                                    .tint(.accentGray)
                                }
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        withAnimation {
                                            todos.removeAll(where: { $0.id == todo.id })
                                        }
                                    } label: {
                                        Label("Delete", systemImage: "trash.fill")
                                    }
                                    // Destructive buttons usually have a default red tint, which is fine.
                                }
                            }
                        }
                        .padding(.top)
                    }
                    // ADD: Make ScrollView background clear to see ContentView gradient
                    .background(Color.clear)
                }
            }
        }
        // ADD: Ensure ZStack background is clear
        .background(Color.clear)
    }
}
