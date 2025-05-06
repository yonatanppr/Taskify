import SwiftUI

struct TodoInputBarView: View {
    @Binding var newTodoText: String
    var onSubmit: () -> Void

    var body: some View {
        HStack {
            TextField("What needs to be done?", text: $newTodoText)
                .disableAutocorrection(true)
                .textInputAutocapitalization(.never)
                .padding(14)
                .background(newTodoText.isEmpty ?
                            Color(.tertiarySystemFill) :
                            Color.blue.opacity(0.1))
                .cornerRadius(12)
                .font(.system(.body, design: .rounded))

            Button(action: {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                onSubmit()
                newTodoText = ""
            }) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.blue)
                    .scaleEffect(newTodoText.isEmpty ? 1.0 : 1.2)
            }
            .padding(.trailing)
        }
        .padding(.horizontal)
        .onAppear {
            let _ = UITextField()
        }
    }
}
