import SwiftUI

struct FilterOption: Identifiable, Codable, Equatable {
    let id: String
    let label: String

    static let allOptions: [FilterOption] = [
        FilterOption(id: "All", label: "All"),
        FilterOption(id: "Completed", label: "Completed"),
        FilterOption(id: "Upcoming", label: "Upcoming"),
        FilterOption(id: "Today", label: "Today"),
        FilterOption(id: "Quick Tics", label: "Quick Tics")
    ]
}

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("theme") private var theme: String = "System"
    @AppStorage("selectedFilters") private var selectedFiltersRaw: String = "[]"

    @State private var selectedFilters: [FilterOption] = SettingsView.loadInitialFilters()

    static func loadInitialFilters() -> [FilterOption] {
        if let data = UserDefaults.standard.string(forKey: "selectedFilters")?.data(using: .utf8),
           let ids = try? JSONDecoder().decode([String].self, from: data) {
            print("[DEBUG] Loaded selectedFiltersRaw: \(ids)")
            return ids.compactMap { id in FilterOption.allOptions.first(where: { $0.id == id }) }
        }
        return Array(FilterOption.allOptions.prefix(3))
    }
    
    // Computed property for list height
    private var listHeight: CGFloat {
        let minVisibleRows = 3
        let rowHeight: CGFloat = 15
        let availableOptions = FilterOption.allOptions.filter { !selectedFilters.contains($0) }.count
        let rows = max(minVisibleRows, selectedFilters.count + availableOptions)
        return CGFloat(rows) * rowHeight
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Todo List Filters")) {
                    FilterSelectionList(selectedFilters: $selectedFilters)
                    Text("Pick up to 3 filters. Drag to reorder. Tap to remove/add.").font(.headline).foregroundColor(.secondary)
                }
                Section(header: Text("Appearance")) {
                    Picker("Appearance", selection: $theme) {
                        Text("System").tag("System")
                        Text("Light").tag("Light")
                        Text("Dark").tag("Dark")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
            }
            .scrollContentBackground(.hidden) // iOS 16+: hide default Form background
            .background(Color("SettingsBackground")) // set custom background color
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        let ids = selectedFilters.map { $0.id }
                        if let data = try? JSONEncoder().encode(ids),
                           let string = String(data: data, encoding: .utf8) {
                            selectedFiltersRaw = string
                        }
                        print("[DEBUG] Done tapped. Final selectedFilters: \(selectedFilters.map { $0.label })")
                        dismiss()
                    }.foregroundColor(.accentColor)
                }
            }
        }
        .onChange(of: selectedFilters) {
            let ids = selectedFilters.map { $0.id }
            if let data = try? JSONEncoder().encode(ids),
               let string = String(data: data, encoding: .utf8) {
                selectedFiltersRaw = string
                print("[DEBUG] Wrote selectedFiltersRaw: \(string)")
            }
        }
        .onAppear {
            if let data = selectedFiltersRaw.data(using: .utf8),
               let ids = try? JSONDecoder().decode([String].self, from: data) {
                let options = ids.compactMap { id in FilterOption.allOptions.first(where: { $0.id == id }) }
                if selectedFilters != options {
                    selectedFilters = options
                }
            }
        }
    }
}
