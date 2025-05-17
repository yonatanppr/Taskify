import SwiftUI

struct TodoInputBarView: View {
    @Binding var newTodoText: String
    var onSubmit: () -> Void
    @FocusState.Binding var isInputActive: Bool

    private let placeholderText = "What needs to be done?"

    var body: some View {
        HStack {
            TextField("", text: $newTodoText)
                .disableAutocorrection(false)
                .textInputAutocapitalization(.never)
                .font(.system(size: 35, weight: .bold))
                .foregroundColor(.primaryText)
                .accentColor(.accentGray)
                .padding(.leading, 16)
                .submitLabel(.done)
                .onSubmit {
                    DispatchQueue.main.async {
                        onSubmit()
                    }
                }
                .focused($isInputActive)
                .overlay(
                    newTodoText.isEmpty
                        ? VStack(alignment: .leading) {
                            Text(placeholderText)
                                .foregroundColor(.primaryText)
                                .font(.system(size: 35, weight: .bold))
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.leading, 16)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .allowsHitTesting(false)
                        : nil,
                    alignment: .leading
                )
            Spacer()
            /*
            Button(action: {
                DispatchQueue.main.async {
                    onSubmit()
                }
            }) {
                ZStack {
                    Circle()
                        .fill(Color.accentBlue)
                        .frame(width: 55, height: 55)
                    Image(systemName: "plus")
                        .font(.system(size: 25, weight: .bold))
                        .foregroundColor(.primaryText)
                }
            }
            .padding(.trailing, 16)
            */
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.clear)
    }
}
