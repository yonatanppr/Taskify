import SwiftUI

@main
struct TaskifyApp: App {
    @AppStorage("theme") private var theme: String = "System"

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(resolveColorScheme())
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        let _ = UIImpactFeedbackGenerator(style: .light)
                    }
                }
        }
    }

    private func resolveColorScheme() -> ColorScheme? {
        switch theme {
        case "Light":
            return .light
        case "Dark":
            return .dark
        default:
            return nil  // Follows system setting
        }
    }
}
