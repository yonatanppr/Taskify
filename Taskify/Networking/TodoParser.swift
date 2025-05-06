import SwiftUI
import Foundation

func parseTodosFromText(_ text: String, completion: @escaping ([String]) -> Void) {
    print("🚀 Starting ChatGPT request")

    guard let url = URL(string: "https://api-inference.huggingface.co/models/HuggingFaceH4/zephyr-7b-beta") else {
        print("❌ Invalid URL")
        completion([])
        return
    }

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("Bearer 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", forHTTPHeaderField: "Authorization")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.timeoutInterval = 100

    let json: [String: Any] = [
        "inputs": """
        Extract individual todo items from the following sentence:

        "\(text)"

        Output the todos one per line, enclosed between the words 'start' and 'stop'.

        Example:

        start
        Shower
        Buy shampoo
        stop
        """
    ]

    do {
        request.httpBody = try JSONSerialization.data(withJSONObject: json)
    } catch {
        print("❌ Failed to encode JSON: \(error)")
        completion([])
        return
    }

    URLSession.shared.dataTask(with: request) { data, response, error in
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
            if httpResponse.statusCode == 429 {
                print("⚠️ Using mock fallback due to quota limit.")
                completion(["Buy groceries", "Call mom", "Read 10 pages of a book"])
            } else {
                completion([])
            }
            return
        }

        if let data = data {
            print("📥 Data received: \(data.count) bytes")
        } else {
            print("❌ No data received")
        }

        guard let data = data else {
            completion([])
            return
        }

        do {
            if let jsonArray = try JSONSerialization.jsonObject(with: data) as? [[String: Any]],
               let generatedText = jsonArray.first?["generated_text"] as? String {
                print("✅ Parsed response: \(generatedText)")
                let lines = generatedText.components(separatedBy: .newlines)
                if let start = lines.firstIndex(where: { $0.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) == "start" }),
                   let stop = lines[start...].firstIndex(where: { $0.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) == "stop" }) {
                    let todos = lines[(start + 1)..<stop]
                        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                        .filter { !$0.isEmpty }
                    completion(Array(todos))
                } else {
                    print("❌ 'start' or 'stop' not found in response")
                    completion([])
                }
            } else {
                print("❌ Unexpected JSON structure")
                completion([])
            }
        } catch {
            print("❌ Decoding error: \(error)")
            if let raw = String(data: data, encoding: .utf8) {
                print("⚠️ Raw fallback response: \(raw)")
            }
            print("⚠️ Using mock fallback due to decoding error.")
            completion(["Take a walk", "Organize desk"])
        }
    }.resume()
    print("📤 Request sent")
}
