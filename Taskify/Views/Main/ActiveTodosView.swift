import SwiftUI
import Foundation
import CoreHaptics

struct ActiveTodosView: View {
    @Binding var todos: [TodoItem]
    @Binding var newTodoText: String
    let reminderManager: ReminderManaging
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
        return Array(filters.prefix(3))
    }
    
    @State private var taskFilter: TaskFilter = .all
    @Namespace private var filterAnimation
    
    private let collapsedCardVisibleHeight: CGFloat = 140
    
    
    var body: some View {
        ZStack {
            GeometryReader { geometryOfActiveTodosView in
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
                }
                .animation(.spring(response: 0.35, dampingFraction: 0.85, blendDuration: 0), value: keyboardResponder.currentHeight)
            }
            .background(Color.clear)
            .ignoresSafeArea(.keyboard, edges: .bottom)
        }
        .sheet(isPresented: $showingSettings, onDismiss: {
            updateTaskFilterIfNeeded()
        }) {
            SettingsView()
        }
        .onChange(of: selectedFiltersRaw) { newValue in
            updateTaskFilterIfNeeded()
        }
        .onChange(of: selectedFilters) { newFilters in
            updateTaskFilterIfNeeded()
        }
        .onAppear {
            updateTaskFilterIfNeeded()
        }
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
            reminderManager: reminderManager
        )
        .transition(.asymmetric(insertion: .move(edge: .bottom).combined(with: .opacity),
                                removal: .opacity))
        .animation(.spring(response: 0.4, dampingFraction: 0.75), value: taskFilter)
    }
}
