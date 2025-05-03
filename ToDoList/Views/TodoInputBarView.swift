import SwiftUI

struct TodoInputBarView: View {
    @Binding var newTodoText: String
    var onSubmit: () -> Void

    var body: some View {
        HStack {
            TextField("What needs to be done?", text: $newTodoText)
                .padding(14)
                .background(newTodoText.isEmpty ?
                            Color(.tertiarySystemFill) :
                            Color.blue.opacity(0.1))
                .animation(.easeInOut(duration: 0.2), value: newTodoText)
                .cornerRadius(12)
                .font(.system(.body, design: .rounded))
                .padding(.horizontal)

            Button(action: onSubmit) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.blue)
                    .scaleEffect(newTodoText.isEmpty ? 1.0 : 1.2)
                    .animation(.easeInOut(duration: 0.2), value: newTodoText)
            }
            .padding(.trailing)
        }
    }
}

#Preview {
    ContentView()
}
