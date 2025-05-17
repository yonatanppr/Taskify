import SwiftUI
import Foundation

func parseTodosFromText(_ text: String, completion: @escaping ([ParsedTodoItem]) -> Void) {
    print("🚀 Starting ChatGPT request")

    guard let url = URL(string: "https://openrouter.ai/api/v1/chat/completions") else {
        print("❌ Invalid URL")
        completion([])
        return
    }

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("Bearer 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", forHTTPHeaderField: "Authorization")
    request.setValue("openrouter-ai", forHTTPHeaderField: "HTTP-Referer")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.timeoutInterval = 60

    let dateFormatter = ISO8601DateFormatter()
    dateFormatter.timeZone = .current
    let isoNow = dateFormatter.string(from: Date())
    print(isoNow)

    let messages: [[String: String]] = [
        ["role": "system", "content": """
        Forget all previous inputs. You are an assistant integrated into a todo list app. Today's current datetime is "\(isoNow)". The user will enter a single sentence describing one or more tasks. Only extract tasks that are mentioned in that sentence. Do not invent or include tasks that are not explicitly described. Return a JSON array where each object has a "title" (capitalized first letter) and a "reminder" (an ISO 8601 datetime like "2024-05-04T14:00:00", or null if no reminder is mentioned). If a task is provided with an unspecific time like "in the evening", "tomorrow morning" or "next week" generate a plausible reminder. If only a day but no time is given (e.g. "tomorrow"), infer a sensible time from context or default to 6am. If the time of the todo is earlier than the current datetime and no day or date is provided assume the task to be meant for the following day at the time that the user provided. Do not include explanations or extra formatting. Return only valid JSON.
        """],
        ["role": "user", "content": "\"\(text)\""]
    ]

    let json: [String: Any] = [
        "model": "mistralai/mistral-7b-instruct:free",
        "messages": messages,
        "temperature": 0.2
    ]

    do {
        request.httpBody = try JSONSerialization.data(withJSONObject: json)
    } catch {
        print("❌ Failed to encode JSON: \(error)")
        completion([])
        return
    }

    let config = URLSessionConfiguration.default
    config.timeoutIntervalForRequest = 60
    config.timeoutIntervalForResource = 60
    let session = URLSession(configuration: config)

    session.dataTask(with: request) { data, response, error in
        if let error = error {
            print("❌ Request failed: \(error.localizedDescription)")
            completion([])
            return
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            print("❌ Invalid response format.")
            completion([])
            return
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            print("❌ HTTP Error: \(httpResponse.statusCode)")
            if let data = data, let errorMessage = String(data: data, encoding: .utf8) {
                print("Response body: \(errorMessage)")
            }
            completion([])
            return
        }

        guard let data = data else {
            print("❌ No data received")
            completion([])
            return
        }

        do {
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                if let choices = json["choices"] as? [[String: Any]],
                   let message = choices.first?["message"] as? [String: Any],
                   let content = message["content"] as? String {
                    print("✅ Parsed response: \(content)")
                    guard let firstChar = content.trimmingCharacters(in: .whitespacesAndNewlines).first,
                          firstChar == "[" else {
                        print("⚠️ Response is not a valid JSON array.")
                        completion([])
                        return
                    }
                    if let data = content.data(using: .utf8),
                       let todosArray = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
                        let todos = todosArray.prefix(10).compactMap { item -> ParsedTodoItem? in
                            guard let title = item["title"] as? String else { return nil }
                            var reminderDate: Date? = nil
                            if let reminderString = item["reminder"] as? String {
                                let localFormatter = DateFormatter()
                                localFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                                localFormatter.timeZone = .current
                                reminderDate = localFormatter.date(from: reminderString)

                                if reminderDate == nil {
                                    let fallbackFormatter = ISO8601DateFormatter()
                                    fallbackFormatter.formatOptions = [.withInternetDateTime]
                                    fallbackFormatter.timeZone = .current
                                    reminderDate = fallbackFormatter.date(from: reminderString)
                                }

                                print("🧪 Attempted to parse '\(reminderString)' → \(String(describing: reminderDate))")
                            }
                            return ParsedTodoItem(title: title, reminder: reminderDate)
                        }
                        completion(todos)
                    } else {
                        completion([])
                    }
                } else if let content = json["output"] as? String ?? json["response"] as? String {
                    print("✅ Parsed fallback response: \(content)")
                    let todos = content
                        .components(separatedBy: .newlines)
                        .map { ParsedTodoItem(title: $0.trimmingCharacters(in: .whitespacesAndNewlines), reminder: nil) }
                        .filter { !$0.title.isEmpty }
                    completion(todos)
                } else {
                    print("❌ Unexpected JSON structure: \(json)")
                    completion([])
                }
            }
        } catch {
            print("❌ Decoding error: \(error)")
            completion([])
        }
    }.resume()
    print("📤 Request sent")
}
