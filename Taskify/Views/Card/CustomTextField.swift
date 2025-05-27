import SwiftUI

struct CustomTextField: UIViewRepresentable {
    class Coordinator: NSObject, UITextFieldDelegate {
        var text: Binding<String>
        var onSubmit: () -> Void

        init(text: Binding<String>, onSubmit: @escaping () -> Void) {
            self.text = text
            self.onSubmit = onSubmit
        }

        func textFieldDidChangeSelection(_ textField: UITextField) {
            text.wrappedValue = textField.text ?? ""
        }

        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            onSubmit()
            if (textField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                textField.resignFirstResponder() // Dismiss keyboard if input is empty
            }
            return false
        }
    }

    @Binding var text: String
    var isFirstResponder: Bool
    var onSubmit: () -> Void

    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.delegate = context.coordinator
        textField.returnKeyType = .done
        textField.font = UIFont.boldSystemFont(ofSize: 24)
        textField.textColor = UIColor(named: "TextColor") ?? .label
        textField.tintColor = UIColor(named: "accentGray") ?? .systemGray
        textField.autocorrectionType = .yes
        return textField
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
        if isFirstResponder && !uiView.isFirstResponder {
            uiView.becomeFirstResponder()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text, onSubmit: onSubmit)
    }
}
