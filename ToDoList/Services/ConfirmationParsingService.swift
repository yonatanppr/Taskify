import Foundation

enum TodoParsingService {
    static func parse(text: String, completion: @escaping ([String]) -> Void) {
        // Simulate async parsing. Replace this with real logic.
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            let lines = text
                .split(separator: "\n")
                .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }

            completion(lines)
        }
    }
}
