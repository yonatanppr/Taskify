
import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("defaultReminderHour") private var defaultReminderHour: Int = 9
    @AppStorage("muteReminders") private var muteReminders: Bool = false
    @AppStorage("startWeekOnMonday") private var startWeekOnMonday: Bool = true
    @AppStorage("aiPromptTone") private var aiPromptTone: String = "Minimal"
    @AppStorage("autoGenerateTasks") private var autoGenerateTasks: Bool = true
    @AppStorage("theme") private var theme: String = "System"

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Notifications")) {
                    Stepper("Default Reminder Time: \(defaultReminderHour):00", value: $defaultReminderHour, in: 0...23)
                    Toggle("Mute Reminders", isOn: $muteReminders)
                    Toggle("Start Week On Monday", isOn: $startWeekOnMonday)
                }

                Section(header: Text("AI Preferences")) {
                    Picker("Prompt Tone", selection: $aiPromptTone) {
                        Text("Formal").tag("Formal")
                        Text("Casual").tag("Casual")
                        Text("Minimal").tag("Minimal")
                    }
                    Toggle("Auto-generate Tasks", isOn: $autoGenerateTasks)
                }

                Section(header: Text("Appearance")) {
                    Picker("Theme", selection: $theme) {
                        Text("Light").tag("Light")
                        Text("Dark").tag("Dark")
                        Text("System").tag("System")
                    }
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }.foregroundColor(.accentColor)
                }
            }
        }
    }
}

