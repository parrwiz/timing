//
//  GeminiService.swift
//  Arkan
//
//  Created by mac on 2/3/25.
//

import Foundation

// Define the structures for the Gemini API response
struct GeminiResponse: Decodable {
    let contents: [Content]
}

struct Content: Decodable {
    let parts: [Part]
}

struct Part: Decodable {
    let text: String
}

class GeminiService {
    private let apiKey = "AIzaSyB_kRm8tOV8YNcWF_86dROdB1G3QpFeHG8"
    
        private let endpoint = "https://generativelanguage.googleapis.com/v1/models/gemini-pro:generateText?key="

        func askGemini(question: String, completion: @escaping (String?) -> Void) {
            guard let url = URL(string: "\(endpoint)\(apiKey)") else {
                completion(nil)
                return
            }
            
            let requestBody: [String: Any] = [
                "prompt": question,
                "temperature": 0.7
            ]
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
            } catch {
                completion(nil)
                return
            }
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {
                    completion(nil)
                    return
                }
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let candidates = json["candidates"] as? [[String: Any]],
                       let text = candidates.first?["output"] as? String {
                        completion(text)
                    } else {
                        completion(nil)
                    }
                } catch {
                    completion(nil)
                }
            }
            
            task.resume()
        }
    }
