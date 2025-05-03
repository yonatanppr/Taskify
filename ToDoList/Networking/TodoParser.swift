import SwiftUI
import Foundation

func parseTodosFromText(_ text: String, completion: @escaping ([String]) -> Void) {
    print("🚀 Starting ChatGPT request")

    guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
        print("❌ Invalid URL")
        completion([])
        return
    }

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("Bearer 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", forHTTPHeaderField: "Authorization")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.timeoutInterval = 10

    let messages: [[String: String]] = [
        ["role": "system", "content": "You are a helpful assistant that extracts individual todo tasks from natural language."],
        ["role": "user", "content": "Extract clear, individual todo items from this text. Output only the todo items, one per line, without numbering, bullet points, or additional text: \(text)"]
    ]

    let json: [String: Any] = [
        "model": "gpt-3.5-turbo",
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

    // URLSession.shared.dataTask(with: request) { data, response, error in
    //     if let error = error {
    //         print("❌ Request failed: \(error.localizedDescription)")
    //         completion([])
    //         return
    //     }
    //
    //     guard let httpResponse = response as? HTTPURLResponse else {
    //         print("❌ Invalid response format.")
    //         completion([])
    //         return
    //     }
    //
    //     guard (200...299).contains(httpResponse.statusCode) else {
    //         print("❌ HTTP Error: \(httpResponse.statusCode)")
    //         if let data = data, let errorMessage = String(data: data, encoding: .utf8) {
    //             print("Response body: \(errorMessage)")
    //         }
    //         if httpResponse.statusCode == 429 {
    //             print("⚠️ Using mock fallback due to quota limit.")
    //             completion(["Buy groceries", "Call mom", "Read 10 pages of a book"])
    //         } else {
    //             completion([])
    //         }
    //         return
    //     }
    //
    //     if let data = data {
    //         print("📥 Data received: \(data.count) bytes")
    //     } else {
    //         print("❌ No data received")
    //     }
    //
    //     guard let data = data else {
    //         completion([])
    //         return
    //     }
    //
    //     do {
    //         let rawString = String(data: data, encoding: .utf8) ?? ""
    //         print("✅ Raw response: \(rawString)")
    //
    //         let response = try JSONDecoder().decode(OpenAIResponse.self, from: data)
    //         let content = response.choices.first?.message.content ?? ""
    //         let todos = content.components(separatedBy: "\n").filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    //         completion(todos)
    //     } catch {
    //         print("❌ Decoding error: \(error)")
    //         if let raw = String(data: data, encoding: .utf8) {
    //             print("⚠️ Raw fallback response: \(raw)")
    //         }
    //         print("⚠️ Using mock fallback due to decoding error.")
    //         completion(["Take a walk", "Organize desk"])
    //     }
    // }.resume()
    // print("📤 Request sent")

    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
        print("🧪 Using local mock response")
        completion(["Mock Task A", "Mock Task B", "Mock Task C"])
    }
}
