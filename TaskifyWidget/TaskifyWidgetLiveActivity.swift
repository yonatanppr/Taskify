import ActivityKit
import WidgetKit
import SwiftUI

struct TaskifyWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct TaskifyWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TaskifyWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension TaskifyWidgetAttributes {
    fileprivate static var preview: TaskifyWidgetAttributes {
        TaskifyWidgetAttributes(name: "World")
    }
}

extension TaskifyWidgetAttributes.ContentState {
    fileprivate static var smiley: TaskifyWidgetAttributes.ContentState {
        TaskifyWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: TaskifyWidgetAttributes.ContentState {
         TaskifyWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: TaskifyWidgetAttributes.preview) {
   TaskifyWidgetLiveActivity()
} contentStates: {
    TaskifyWidgetAttributes.ContentState.smiley
    TaskifyWidgetAttributes.ContentState.starEyes
}
