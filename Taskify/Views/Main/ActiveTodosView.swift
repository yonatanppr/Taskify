import SwiftUI
import Foundation
import CoreHaptics

struct ActiveTodosView: View {
    @Binding var todos: [TodoItem]
    @Binding var newTodoText: String
    let reminderManager: ReminderManaging
    @Binding var showingDatePickerForIndex: Int?
    @Binding var reminderDate: Date
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    @State private var showingSettings = false
    
    @StateObject private var keyboardResponder = KeyboardResponder()
    @State private var currentDateText: String = ""
    
    @AppStorage("selectedFilters") private var selectedFiltersRaw: String = "[]"
    
    enum TaskFilter: String, CaseIterable {
        case all = "All"
        case upcoming = "Upcoming"
        case completed = "Completed"
        case today = "Today"
        case quickTics = "Quick Tics"
    }
    
    private var selectedFilters: [TaskFilter] {
        // Decode the JSON string from settings into an array of raw values
        guard let data = selectedFiltersRaw.data(using: .utf8),
              let decoded = try? JSONDecoder().decode([String].self, from: data) else {
            print("[DEBUG] selectedFilters: using default [.all, .upcoming, .completed]")
            return [.all, .upcoming, .quickTics]
        }
        let filters = decoded.compactMap { TaskFilter(rawValue: $0) }
        let widgetTodoCount = UserDefaults.standard.integer(forKey: "widget_todo_count_debug")
        return Array(filters.prefix(3))
    }
    
    @State private var taskFilter: TaskFilter = .all
    @Namespace private var filterAnimation
    
    private let collapsedCardVisibleHeight: CGFloat = 140
    
    @State private var selectedTodoForReminder: TodoItem? = nil
    @State private var selectedTodoFrame: CGRect? = nil
    
var body: some View {
    ZStack {
        mainLayout
    }
    .sheet(isPresented: $showingSettings, onDismiss: {
        updateTaskFilterIfNeeded()
    }) {
        SettingsView()
    }
    .onChange(of: selectedFiltersRaw) { _ in
        updateTaskFilterIfNeeded()
    }
    .onChange(of: selectedFilters) { _ in
        updateTaskFilterIfNeeded()
    }
    .onAppear {
        updateTaskFilterIfNeeded()
    }
}

private var mainLayout: some View {
    GeometryReader { _ in
        Group {
            cardStack
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: keyboardResponder.currentHeight)
    }
    .background(Color.clear)
    .ignoresSafeArea(.keyboard, edges: .bottom)
}

private var cardStack: some View {
    ZStack(alignment: .bottom) {
        mainContent

        DraggableInputCardView(
            newTodoText: $newTodoText,
            onSubmit: {
                Task { await handleNewTodoSubmission() }
            },
            errorMessage: $errorMessage,
            todos: $todos
        )
        .zIndex(1)

        if let todo = selectedTodoForReminder, let frame = selectedTodoFrame {
            ReminderEditorCard(
                todo: todo,
                initialFrame: frame,
                reminderManager: reminderManager,
                onDismiss: {
                    withAnimation {
                        selectedTodoForReminder = nil
                        selectedTodoFrame = nil
                    }
                },
                onSave: { updatedTodo in
                    if let index = todos.firstIndex(where: { $0.id == updatedTodo.id }) {
                        todos[index] = updatedTodo
                    }
                    withAnimation {
                        selectedTodoForReminder = nil
                        selectedTodoFrame = nil
                    }
                },
                namespace: filterAnimation
            )
            .transition(.identity)
            .zIndex(10)
        }
    }
    .animation(nil, value: showingDatePickerForIndex)
}
    
    private var mainContent: some View {
        VStack(spacing: 24) {
            HeaderBarView(
                showingSettings: $showingSettings,
                currentDateText: currentDateText
            )
            FilterBarView(
                selectedFilters: .constant(selectedFilters),
                taskFilter: $taskFilter,
                filterAnimation: filterAnimation
            )
            todoSection
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity)
        .zIndex(0)
    }
    
    private func updateTaskFilterIfNeeded() {
        if !selectedFilters.contains(taskFilter) {
            taskFilter = selectedFilters.first ?? .all
            print("[DEBUG] selectedFilters updated: \(selectedFilters.map { $0.rawValue })")
            let widgetTodoCount = UserDefaults.standard.integer(forKey: "widget_todo_count_debug")
            print("[DEBUG] Widget decoded todos count: \(widgetTodoCount)")
        }
    }
    
    private func handleNewTodoSubmission() async {
        await TodoGenerationHandler.handleNewTodoSubmission(
            text: newTodoText,
            todos: $todos,
            isLoading: $isLoading,
            errorMessage: $errorMessage,
            reminderManager: reminderManager
        ) {
            newTodoText = ""
        }
    }
    // MARK: - Extracted Subviews
    
    private var todoSection: some View {
        ActiveTodoListSection(
            todos: $todos,
            taskFilter: taskFilter,
            reminderDate: $reminderDate,
            reminderManager: reminderManager,
            selectedTodoForReminder: $selectedTodoForReminder,
            selectedTodoFrame: $selectedTodoFrame
        )
        .transition(.asymmetric(insertion: .move(edge: .bottom).combined(with: .opacity),
                                removal: .opacity))
        .animation(.spring(response: 0.4, dampingFraction: 0.75), value: taskFilter)
    }
}
