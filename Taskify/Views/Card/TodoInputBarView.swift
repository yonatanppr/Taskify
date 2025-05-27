import SwiftUI

struct TodoInputBarView: View {
    @Binding var newTodoText: String
    var onSubmit: () -> Void
    @FocusState.Binding var isInputActive: Bool

    private let placeholderText = "Add task ..."

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 30)
                .stroke(Color("InputBarLine"), lineWidth: 2)
            HStack {
                CustomTextField(text: $newTodoText, isFirstResponder: isInputActive, onSubmit: onSubmit)
                    .padding(.leading, 16)
                    .frame(height: 40)
                    .overlay(
                        newTodoText.isEmpty
                            ? VStack(alignment: .leading) {
                                Text(placeholderText)
                                    .foregroundColor(Color("TextColor"))
                                    .font(.system(size: 21, weight: .bold))
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
                        if newTodoText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            isInputActive = false
                        } else {
                            onSubmit()
                            isInputActive = true
                        }
                    }
                }) {
                    ZStack {
                        Circle()
                            .fill(Color("SubmitButton"))
                            .frame(width: 45, height: 45)
                        Image(systemName: "plus")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 18, height: 18)
                            .foregroundColor(Color("PlusIcon"))
                    }
                }
                .padding(.trailing, 0)
                
            }
            .padding(8)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 4).padding(.bottom, 8)
        .background(Color.clear)
    }
}
