import SwiftUI

struct TodoInputBarView: View {
    @Binding var newTodoText: String
    var onSubmit: () -> Void
    @FocusState.Binding var isInputActive: Bool

    private let placeholderText = "Add task ..."

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.accentGray, lineWidth: 1)
            HStack {
                TextField("", text: $newTodoText)
                    .disableAutocorrection(false)
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
                
                Button(action: {
                    DispatchQueue.main.async {
                        onSubmit()
                    }
                }) {
                    ZStack {
                        Circle()
                            .fill(Color.plusCircle)
                            .frame(width: 55, height: 55)
                        Image(systemName: "plus")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25, height: 25)
                            .foregroundColor(.white)
                    }
                }
                .padding(.trailing, 16)
                
            }
            .padding(8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.clear)
    }
}
