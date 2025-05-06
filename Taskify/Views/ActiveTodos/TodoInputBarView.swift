import SwiftUI

struct TodoInputBarView: View {
    @Binding var newTodoText: String
    var onSubmit: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            TextField("What needs to be done?", text: $newTodoText)
                .disableAutocorrection(true)
                .textInputAutocapitalization(.never)
                .padding(16)
                // CHANGE: Use componentBackground for the TextField
                .background(Color.componentBackground)
                .cornerRadius(16)
                .font(.system(size: 18, weight: .medium, design: .rounded))
                // ADD: A subtle border to distinguish the text field
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.appBackground, lineWidth: 1)
                )


            Button(action: {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                onSubmit()
                // REMOVE: newTodoText = "" (This is handled by the TodoGenerationHandler now)
            }) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 34))
                    // CHANGE: Use primaryAppBlue for the button
                    .foregroundColor(Color.primaryAppBlue)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        // CHANGE: Use componentBackground for the bar background
        .background(Color.componentBackground)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 4) // Slightly adjusted shadow
        // REMOVE: onAppear block - this UIKit workaround for keyboard might not be necessary or could be handled differently if still needed. Let's remove it for now for cleaner design focus.
        // If keyboard pre-warming is still desired, it should be managed at a higher level (e.g., in ContentViewModel or AppDelegate).
    }
}
