import Foundation
import SwiftyChrono

struct ParsedTodo {
    let title: String
    let reminderDate: Date?
    let labels: [String]
}

class NaturalLanguageParser {
    static let shared = NaturalLanguageParser()
    private let dateDetector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.date.rawValue)
    
    func parse(_ input: String) -> ParsedTodo {
        var title = input
        var reminderDate: Date? = nil
        var labels: [String] = []
        
        // Use SwiftyChrono for date parsing
        let chrono = Chrono()
        let results = chrono.parse(text: input)
        if let first = results.first {
            reminderDate = first.start.date
            if let range = title.range(of: first.text) {
                title.removeSubrange(range)
            }
        }

        // Extract labels (e.g., #work, #home)
        let labelRegex = try? NSRegularExpression(pattern: "#(\\w+)", options: [])
        if let regex = labelRegex {
            let matches = regex.matches(in: title, options: [], range: NSRange(location: 0, length: title.utf16.count))
            for match in matches {
                if let range = Range(match.range(at: 1), in: title) {
                    labels.append(String(title[range]))
                }
            }
            // Remove labels from title
            title = regex.stringByReplacingMatches(in: title, options: [], range: NSRange(location: 0, length: title.utf16.count), withTemplate: "").trimmingCharacters(in: .whitespaces)
        }

        return ParsedTodo(title: title, reminderDate: reminderDate, labels: labels)
    }
}
