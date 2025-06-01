import WidgetKit
import SwiftUI

@main
struct TaskifyWidget: Widget {
    let kind: String = "TaskifyWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            WidgetEntryView(entry: entry)
                .containerBackground(Color("AppBackground"), for: .widget)
        }
        .configurationDisplayName("Taskify")
        .description("Displays your tasks due today.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
