import SwiftUI
import Foundation
import CoreHaptics

struct ActiveTodosView: View {
    @Binding var todos: [TodoItem]
    @Binding var newTodoText: String
    let reminderManager: ReminderManaging
    @Binding var showingDatePickerForIndex: Int?
    @Binding var reminderDate: Date
    @Binding var showConfirmation: Bool
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
    
    
    var body: some View {
        ZStack {
            GeometryReader { geometryOfActiveTodosView in
                Group {
                    ZStack(alignment: .bottom) {
                        VStack(spacing: 24) {
                            headerBar
                            filterBar
                            loadingIndicator
                            todoSection
                        }
                        .padding(.horizontal, 16)
                        .frame(maxWidth: .infinity)
                        .zIndex(0)
                        
                        
                        DraggableInputCardView(
                            newTodoText: $newTodoText,
                            onSubmit: {
                                Task { await handleNewTodoSubmission() }
                            },
                            errorMessage: $errorMessage,
                            todos: $todos
                        )
                        .zIndex(1)
                        
                        if showConfirmation {
                            VStack {
                                Spacer()
                                ConfirmationToastView(message: "Reminder set!")
                                    .padding(.bottom, collapsedCardVisibleHeight + 10 + keyboardResponder.currentHeight)
                                    .transition(.move(edge: .bottom).animation(.spring(response: 0.4, dampingFraction: 0.7)))
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .zIndex(2)
                            .allowsHitTesting(false)
                        }
                    }
                    .animation(nil, value: showingDatePickerForIndex)
                }
                .animation(.spring(response: 0.35, dampingFraction: 0.85, blendDuration: 0), value: keyboardResponder.currentHeight)
            }
            .background(Color.clear)
            .ignoresSafeArea(.keyboard, edges: .bottom)
            
            if let index = showingDatePickerForIndex {
                ReminderOverlayView(
                    index: index,
                    todos: $todos,
                    reminderDate: $reminderDate,
                    showingDatePickerForIndex: $showingDatePickerForIndex,
                    showConfirmation: $showConfirmation,
                    reminderManager: reminderManager
                )
            }
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
            if CHHapticEngine.capabilitiesForHardware().supportsHaptics {
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.prepare()
                generator.impactOccurred()
            }
        }
    }
    // MARK: - Extracted Subviews
    
    private var headerBar: some View {
        HStack(spacing: 12) {
            Button(action: {}) {
                Image("ProfileIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .padding(12)
                    .foregroundColor(Color("ButtonIcon"))  // Optional
                    .background(
                        ZStack {
                            Color.clear.background(.ultraThinMaterial)
                            Color("UnselectedFilter")
                        }
                    )
                    .clipShape(Circle())
            }
            
            Button(action: { showingSettings = true }) {
                Image("SettingsIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .padding(12)
                    .foregroundColor(Color("ButtonIcon"))  // Optional
                    .background(
                        ZStack {
                            Color.clear.background(.ultraThinMaterial)
                            Color("UnselectedFilter")
                        }
                    )
                    .clipShape(Circle())
            }
            
            Spacer()
            
            Text(currentDateText)
                .font(.system(size: 65, weight: .bold, design: .rounded))
                .foregroundColor(Color("DateColor"))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .truncationMode(.tail)
        }
        .padding(.horizontal, 20)
        .padding(.top, 35)
        .onAppear {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd MMMM"
            currentDateText = formatter.string(from: Date())
        }
    }
    
    private var filterBar: some View {
        HStack(spacing: 0) {
            ForEach(selectedFilters, id: \.self) { filter in
                Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        taskFilter = filter
                    }
                }) {
                    ZStack {
                        if taskFilter == filter {
                            RoundedRectangle(cornerRadius: 22)
                                .fill(Color("SelectedFilter"))
                                .matchedGeometryEffect(id: "filterBackground", in: filterAnimation)
                                .allowsHitTesting(false)
                        }
                        
                        Text(filter.rawValue)
                            .font(.callout)
                            .fontWeight(.medium)
                            .foregroundColor(Color("FilterText"))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 38)
                }
                .contentShape(Rectangle())
                .buttonStyle(PlainButtonStyle())
            }
        }
        .id(selectedFilters.map { $0.rawValue }.joined(separator: "-")) // Stronger ID to force update
        .background(Color("UnselectedFilter"), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .padding(.horizontal, 20)
    }
    
    private var todoSection: some View {
        ActiveTodoListSection(
            todos: $todos,
            taskFilter: taskFilter,
            reminderDate: $reminderDate,
            showConfirmation: $showConfirmation,
            reminderManager: reminderManager
        )
        .transition(.asymmetric(insertion: .move(edge: .bottom).combined(with: .opacity),
                                removal: .opacity))
        .animation(.spring(response: 0.4, dampingFraction: 0.75), value: taskFilter)
    }
    
    private var loadingIndicator: some View {
        Group {
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .accentGray))
                    .scaleEffect(1.4)
                    .transition(.scale.animation(.spring(response: 0.3, dampingFraction: 0.6)))
            }
        }
    }
    
}
