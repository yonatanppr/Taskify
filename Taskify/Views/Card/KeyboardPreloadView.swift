import SwiftUI
import Foundation

struct KeyboardPreloadView: View {
    @State var hiddenInput = ""
    @FocusState var dummyFocus: Bool

    var body: some View {
        ManualFocusTextField(text: $hiddenInput, placeholder: "", isFirstResponder: dummyFocus)
            .padding(.leading, 4)
            .opacity(0)
            .frame(width: 0, height: 0)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    dummyFocus = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        dummyFocus = false
                    }
                }
            }
    }
}


struct ManualFocusTextField: UIViewRepresentable {
    class Coordinator: NSObject, UITextFieldDelegate {
        var text: Binding<String>

        init(text: Binding<String>) {
            self.text = text
        }

        func textFieldDidChangeSelection(_ textField: UITextField) {
            text.wrappedValue = textField.text ?? ""
        }
    }

    @Binding var text: String
    var placeholder: String
    var isFirstResponder: Bool

    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.font = UIFont.boldSystemFont(ofSize: 24)
        textField.delegate = context.coordinator
        return textField
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
        if isFirstResponder && !uiView.isFirstResponder {
            uiView.becomeFirstResponder()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text)
    }
}
