import Combine
import UIKit
import SwiftUI

final class KeyboardResponder: ObservableObject {
    @Published private(set) var currentHeight: CGFloat = 0
    private var cancellable: AnyCancellable?

    init() {
        let keyboardWillShow = NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .compactMap { $0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect }
            .map { $0.height }
            .delay(for: .milliseconds(50), scheduler: DispatchQueue.main)


        let keyboardWillHide = NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .map { _ in CGFloat(0) }
            .delay(for: .milliseconds(50), scheduler: DispatchQueue.main)


        cancellable = Publishers.Merge(keyboardWillShow, keyboardWillHide)
            .subscribe(on: DispatchQueue.main) // Ensure operations are on the main thread
            .assign(to: \.currentHeight, on: self)
    }
}
