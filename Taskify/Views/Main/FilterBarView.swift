import SwiftUI

struct FilterBarView: View {
    @Binding var selectedFilters: [ActiveTodosView.TaskFilter]
    @Binding var taskFilter: ActiveTodosView.TaskFilter
    var filterAnimation: Namespace.ID

    var body: some View {
        HStack(spacing: 0) {
            ForEach(selectedFilters, id: \.self) { filter in
                Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        taskFilter = filter
                    }
                }) {
                    ZStack {
                        if taskFilter == filter {
                            RoundedRectangle(cornerRadius: 18)
                                .fill(Color("SelectedFilter"))
                                .matchedGeometryEffect(id: "filterBackground", in: filterAnimation)
                                .allowsHitTesting(false)
                        }

                        Text(filter.rawValue)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(Color("FilterText"))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 32)
                }
                .contentShape(Rectangle())
                .buttonStyle(PlainButtonStyle())
            }
        }
        .id(selectedFilters.map { $0.rawValue }.joined(separator: "-"))
        .background(Color("UnselectedFilter"), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .padding(.horizontal, 20)
    }
}
