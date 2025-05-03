import SwiftUI
import Foundation

struct ActiveTodosView: View {
    @Binding var todos: [TodoItem]
    @Binding var newTodoText: String
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    @State private var showingDatePickerForIndex: Int? = nil
    @State private var showConfirmation: Bool = false
    @State private var reminderDate: Date = Date()

    var body: some View {
        ScrollViewReader { proxy in
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color(red: 0.95, green: 0.97, blue: 1.0), Color(red: 0.98, green: 0.94, blue: 1.0)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 16) {
                    TodoInputBarView(newTodoText: $newTodoText) {
                        guard !newTodoText.isEmpty else { return }
                        isLoading = true
                        errorMessage = nil
                        parseTodosFromText(newTodoText) { items in
                            DispatchQueue.main.async {
                                withAnimation(.spring()) {
                                    if items.isEmpty {
                                        errorMessage = "Failed to generate todos. Please try again."
                                    } else {
                                        for title in items {
                                            todos.append(TodoItem(title: title.trimmingCharacters(in: .whitespacesAndNewlines)))
                                        }
                                        newTodoText = ""
                                    }
                                    isLoading = false
                                }
                            }
                        }
                    }

                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                            .scaleEffect(1.2)
                            .transition(.opacity)
                            .padding(.top, -8)
                    }

                    if let message = errorMessage {
                        Text(message)
                            .foregroundColor(.red)
                            .font(.footnote)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                            .transition(.opacity)
                    }

                    List {
                        ForEach(todos.indices, id: \.self) { index in
                            if !todos[index].isDone {
                                TodoRowView(
                                    todo: todos[index],
                                    isDatePickerVisible: showingDatePickerForIndex == index,
                                    reminderDate: $reminderDate,
                                    onToggle: {
                                        withAnimation(.easeInOut(duration: 0.25)) {
                                            todos[index].isDone.toggle()
                                        }
                                    },
                                    onBellTap: {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            if showingDatePickerForIndex == index {
                                                showingDatePickerForIndex = nil
                                            } else {
                                                showingDatePickerForIndex = index
                                            }
                                        }
                                    },
                                    onDateSelected: {
                                        withAnimation(.easeInOut) {
                                            showConfirmation = true
                                            showingDatePickerForIndex = nil
                                        }
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                            withAnimation {
                                                showConfirmation = false
                                            }
                                        }
                                    }
                                )
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button {
                                        withAnimation(.easeInOut(duration: 0.25)) {
                                            todos[index].isDone.toggle()
                                        }
                                    } label: {
                                        Label("Complete", systemImage: "checkmark")
                                    }
                                    .tint(.green)
                                }
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .listStyle(.plain)
                    .padding(.top)

                    if showConfirmation {
                        ConfirmationToastView(message: "✅ Reminder set!")
                    }

                    Spacer()
                }
                .padding()
                .onAppear {
                    withAnimation(.easeOut(duration: 0.5)) {}
                }
            }
        }
    }
}
// MARK: - CodeAI Output
// *** PLEASE SUBSCRIBE TO GAIN CodeAI ACCESS! ***
/// To subscribe, open CodeAI MacOS app and tap SUBSCRIBE
