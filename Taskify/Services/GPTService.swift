import Foundation

struct ParsedTodoItem: Decodable {
    let title: String
    let reminder: Date?
}


final class GPTService {
    static let shared = GPTService()

    private let apiURL = URL(string: "https://openrouter.ai/api/v1/chat/completions")!
    private let apiKey: String

    private init() {
        // Load API key securely from Info.plist, environment, or Keychain!
        self.apiKey = "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"
    }

    /// Generate todos using GPT, parsing the structured result.
    func generateTodos(from text: String) async throws -> [ParsedTodoItem] {
        print("🟡 [GPTService] Starting generateTodos with prompt: \(text)")
        var request = URLRequest(url: apiURL)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.timeZone = .current
        let isoNow = dateFormatter.string(from: Date())
        print(isoNow)

        let payload: [[String: String]] = [
            ["role": "system", "content": """
            Forget all previous inputs. You are an assistant integrated into a todo list app. Today's current datetime is "\(isoNow)". The user will enter a single sentence describing one or more tasks. Only extract tasks that are mentioned in that sentence. Do not invent or include tasks that are not explicitly described. Return a JSON array where each object has a "title" (capitalized first letter) and a "reminder" (an ISO 8601 datetime like "2024-05-04T14:00:00", or null if no reminder is mentioned). If a task is provided with an unspecific time like "in the evening", "tomorrow morning" or "next week" generate a plausible reminder. If only a day but no time is given (e.g. "tomorrow"), infer a sensible time from context or default to 6am. If the time of the todo is earlier than the current datetime and no day or date is provided assume the task to be meant for the following day at the time that the user provided. Do not include explanations or extra formatting. Return only valid JSON.
            """],
            ["role": "user", "content": "\"\(text)\""]
        ]
        let json: [String: Any] = [
            "model": "mistralai/mistral-7b-instruct:free",
            "messages": payload,
            "temperature": 0.2
        ]

        do {
            let bodyData = try JSONSerialization.data(withJSONObject: json)
            request.httpBody = bodyData
            print("🟡 [GPTService] Request body: \(String(data: bodyData, encoding: .utf8) ?? "<unprintable>")")
        } catch {
            print("❌ Failed to encode JSON: \(error)")
            return []
        }

        let (data, response) = try await URLSession.shared.data(for: request)
        if let httpResponse = response as? HTTPURLResponse {
            print("🟡 [GPTService] HTTP Status: \(httpResponse.statusCode)")
            if httpResponse.statusCode != 200 {
                print("🔴 [GPTService] Error response body: \(String(data: data, encoding: .utf8) ?? "<unprintable>")")
                throw URLError(.badServerResponse)
            }
        } else {
            print("🟡 [GPTService] Non-HTTP response: \(response)")
        }

        struct OpenAIChoiceMessage: Decodable {
            let role: String
            let content: String
        }
        struct OpenAIChoice: Decodable {
            let message: OpenAIChoiceMessage
        }
        struct OpenAIResponse: Decodable {
            let choices: [OpenAIChoice]
        }

        do {
            let openAIResponse = try JSONDecoder().decode(OpenAIResponse.self, from: data)
            guard let rawContent = openAIResponse.choices.first?.message.content else {
                print("🔴 [GPTService] No content in response.")
                return []
            }
            print("🟢 [GPTService] GPT content: \(rawContent)")
            guard let todosData = rawContent.data(using: .utf8) else {
                print("🔴 [GPTService] Could not convert content to Data")
                return []
            }
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let todos = try decoder.decode([ParsedTodoItem].self, from: todosData)
            print("🟢 [GPTService] Decoded \(todos.count) todos.")
            return todos
        } catch {
            print("🔴 [GPTService] Decoding failed with error: \(error)")
            print("🔴 [GPTService] Raw response data: \(String(data: data, encoding: .utf8) ?? "<unprintable>")")
            throw error
        }
    }
}
