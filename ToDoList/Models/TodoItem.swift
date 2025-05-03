import SwiftUI
import Foundation


struct TodoItem: Identifiable {
    let id = UUID()
    let title: String
    var isDone: Bool = false
}
