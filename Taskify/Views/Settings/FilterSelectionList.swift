import SwiftUI

struct FilterSelectionList: View {
    @Binding var selectedFilters: [FilterOption]
    
    private let rowHeight: CGFloat = 32

    var body: some View {
        List {
            Section {
                ForEach(selectedFilters) { filter in
                    HStack {
                        Text(filter.label)
                        Spacer()
                        Image(systemName: "line.horizontal.3")
                            .foregroundColor(.gray)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if let index = selectedFilters.firstIndex(of: filter) {
                            selectedFilters.remove(at: index)
                        }
                    }
                    .frame(height: rowHeight)
                }
                .onMove { indices, newOffset in
                    selectedFilters.move(fromOffsets: indices, toOffset: newOffset)
                }
            }
            
            Section {
                ForEach(FilterOption.allOptions.filter { !selectedFilters.contains($0) }) { filter in
                    HStack {
                        Text(filter.label)
                        Spacer()
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.accentColor)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if selectedFilters.count < 3 {
                            selectedFilters.append(filter)
                        }
                    }
                    .frame(height: rowHeight)
                }
                .onMove { indices, newOffset in
                    selectedFilters.move(fromOffsets: indices, toOffset: newOffset)
                }
            }
        }
        .environment(\.editMode, .constant(.active))
    }
}
