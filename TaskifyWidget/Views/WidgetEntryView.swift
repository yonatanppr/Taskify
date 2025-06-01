import Foundation
import SwiftUI

struct WidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: TaskEntry

    var body: some View {
        Group {
            switch family {
            case .systemSmall:
                SmallCardView(entry: entry)
            case .systemLarge:
                LargeCardView(entry: entry)
            default:
                MainCardView(entry: entry)
            }
        }
    }
}
