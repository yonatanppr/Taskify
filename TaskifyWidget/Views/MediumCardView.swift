import SwiftUI

struct MainCardView: View {
    let entry: TaskEntry

    var body: some View {
        ZStack {
            HStack(spacing: 20) {
                VStack(spacing: 8) {
                    HStack(spacing: 4) {
                        Text(formattedDay(entry.date))
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(Color("TextColor"))
                        Text(formattedMonth(entry.date))
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(Color("TextColor"))
                    }
                    Text("\(entry.todos.count) tasks")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            Capsule().fill(Color("SubmitButton"))
                        )
                }
                .frame(minWidth: 60)
                .frame(maxHeight: .infinity)
                .multilineTextAlignment(.center)
                .padding(.vertical, 18)

                GeometryReader { geo in
                    VStack {
                        Spacer()
                        VStack(spacing: 10) {
                            if entry.todos.isEmpty {
                                Text("No tasks due today.")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(Color("FilterBar + Menu/FilterText"))
                                    .multilineTextAlignment(.center)
                            } else {
                                ForEach(entry.todos.prefix(3)) { todo in
                                    TaskRow(todo: todo)
                                }
                            }
                        }
                        Spacer()
                    }
                    .frame(width: geo.size.width, height: geo.size.height)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .padding(18)
        }
    }

    private func formattedDay(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("d")
        return formatter.string(from: date)
    }

    private func formattedMonth(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("MMM")
        return formatter.string(from: date)
    }
}
