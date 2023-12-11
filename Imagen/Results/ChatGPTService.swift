//
//  ChatGPTService.swift
//  Imagen
//
//  Created by Dhruv Bellani on 12/11/23.
//

import UIKit

class ChatGPTService {
    private let apiKey: String
    private let apiUrlString = "https://api.openai.com/v1/chat/completions"
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    func sendMessage(message: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: apiUrlString) else {
            completion(.failure(URLError(.badURL)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let body: [String: Any] = [
            "model": "gpt-4",
            "messages": [["role": "system", "content": "You're a friendly, helpful assistant"],
                         ["role": "user", "content": message]]
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            completion(.failure(error))
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                print("HTTP Status Code: \(httpResponse.statusCode)")
            }
            
            if let mimeType = response?.mimeType {
                print("MIME Type: \(mimeType)")
            }
            
            if let data = data, let responseString = String(data: data, encoding: .utf8) {
                print("Raw Response: \(responseString)")
            }
            
            guard let data = data else {
                completion(.failure(URLError(.cannotParseResponse)))
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                guard let dictionary = json as? [String: Any],
                      let choices = dictionary["choices"] as? [[String: Any]],
                      let firstChoice = choices.first,
                      let text = firstChoice["message"] as? [String: String],
                      let content = text["content"] else {
                    throw URLError(.cannotParseResponse)
                }
                
                let lines = content.components(separatedBy: .newlines)
                print(lines)
                // Arrays to hold the parts before and after the colon
               // var titles = [String]()
                //var descriptions = [String]()
                
                // Iterate over the lines array, looking for titles and descriptions
//                for (index, line) in lines.enumerated() {
//                    if line.range(of: #"^\d+\.\s"#, options: .regularExpression) != nil {
//                        // This is a title line
//                        let title = line.trimmingCharacters(in: .whitespacesAndNewlines)
//                        titles.append(title)
//                    } else if !line.isEmpty && !line.hasSuffix("upcycle your old vases into something new and useful.") && index > 0 && lines[index - 1].range(of: #"^\d+\.\s"#, options: .regularExpression) != nil {
//                        // This is a description line, which comes after a title line
//                        let description = line.trimmingCharacters(in: .whitespacesAndNewlines)
//                        descriptions.append(description)
//                    }
//                }
                
//                for (index, line) in lines.enumerated() {
//                    if line.range(of: #"^\d+\.\s"#, options: .regularExpression) != nil {
//                        // This is a title line
//                        let title = line.trimmingCharacters(in: .whitespacesAndNewlines)
//                        titles.append(title)
//                    } else if !line.isEmpty && index > 0 && lines[index - 1].range(of: #"^\d+\.\s"#, options: .regularExpression) != nil {
//                        // This is a description line, which comes after a title line
//                        let description = line.trimmingCharacters(in: .whitespacesAndNewlines)
//                        if descriptions.isEmpty || descriptions.last != "" {
//                            // Start a new description
//                            descriptions.append(description)
//                        } else {
//                            // Continue the existing description
//                            descriptions[descriptions.count - 1] += "\n\n" + description
//                        }
//                    }
//                }
//
//                // If there's an empty description at the end, remove it
//                if let last = descriptions.last, last.isEmpty {
//                    descriptions.removeLast()
//                }
//
//                // Log titles and descriptions
//                print("Titles:", titles)
//                print("Descriptions:", descriptions)
                
                completion(.success(content))
            } catch {
                completion(.failure(error))
            }
        }
            task.resume()
        }
        
    }

