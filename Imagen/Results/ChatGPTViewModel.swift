import Foundation
//import OpenAIKit
import Combine
import SwiftUI

class ChatGPTViewModel: ObservableObject {
    @Published var userInput: String = ""
    @Published var response: String = ""
    @Published var titles: [String] = []
    @Published var descriptions: [String] = []
    @Published var imageUrls: [URL] = []
    @Published var isAnalyzingImage = false
    
    private var cancellables = Set<AnyCancellable>()

    private let chatService: ChatGPTService
    
   // let openAI = OpenAI(Configuration(organizationId: "Personal", apiKey: "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"))

    init(chatService: ChatGPTService) {
        self.chatService = chatService
    }
    
//    func generateImagesForTitles() {
//        print("Went into the images generation function")
//        for title in titles {
//            let prompt = "generate an image of a \(userInput) being upcycled as an \(title). Make it realistic as possible. Use pastel colours"
//
//            generateImage(with: prompt) { [weak self] result in
//                DispatchQueue.main.async {
//                    switch result {
//                    case .success(let url):
//                        self?.imageUrls.append(url)
//                    case .failure(let error):
//                        print("Error generating image: \(error)")
//                        // Handle error, perhaps by appending a placeholder URL or image
//                    }
//                }
//            }
//        }
//    }
    
    func generateImagesForTitles() {
        var tempImageUrls = [Int: URL]() // Temporary dictionary to store URLs with indices
        self.isAnalyzingImage = true

        for (index, title) in titles.enumerated() {
            let prompt = "generate an image of a \(userInput) being upcycled as \(title). Make sure that the \(userInput) is the main article in the image. Emphesis on \(userInput) Make it realistic as possible. Try and give real world features it. Use nice warm colours nothing too bright. Make use of \(userInput) as the main item"
            
            generateImage(with: prompt) { [weak self] result in
                DispatchQueue.main.async {
                    self?.isAnalyzingImage=false
                    switch result {
                    case .success(let url):
                        tempImageUrls[index] = url // Store URL with its corresponding index

                        if tempImageUrls.count == self?.titles.count {
                            // All images have been loaded, now sort and update imageUrls
                            self?.imageUrls = tempImageUrls.sorted(by: { $0.key < $1.key }).map { $0.value }
                        }

                    case .failure(let error):
                        print("Error generating image: \(error)")
                        // Handle error, perhaps by appending a placeholder URL
                    }
                }
            }
        }
    }

    
    func generateImage(with prompt: String, completion: @escaping (Result<URL, Error>) -> Void) {
        let endpoint = "https://api.openai.com/v1/images/generations"
        guard let url = URL(string: endpoint) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer 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", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "model": "dall-e-3",
            "prompt": prompt,
            "size": "1024x1024",
            "quality": "standard",
            "n": 1
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data,
                  let jsonResponse = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let dataArr = jsonResponse["data"] as? [[String: Any]],
                  let firstImage = dataArr.first,
                  let imageUrlStr = firstImage["url"] as? String,
                  let imageUrl = URL(string: imageUrlStr) else {
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])))
                return
            }

            completion(.success(imageUrl))
        }.resume()
    }

    
    func sendMessage() {
        
        self.titles.removeAll()
        self.descriptions.removeAll()
        self.imageUrls.removeAll()

        let modifiedInput = "So I need a response for an app that I am writing. Can you give me 5 ways to upcycle a \(userInput)? Think of ways that we can reuse the item as something else that it previously wasent, Can you add a small 250 - 300 word description to each of the ways that you give. Can you also add a space (a \n) between the idea and its following description. Can you skip out any formalities and provide me directly with the points. Can you number them like 1. 2. "

        chatService.sendMessage(message: modifiedInput) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let content):
                        let lines = content.components(separatedBy: .newlines)
                        var tempTitles = [String]()
                        var tempDescriptions = [String]()
                        var currentDescription = ""

                        for line in lines {
                            if line.range(of: #"^\d+\.\s"#, options: .regularExpression) != nil {
                                // This is a title line
                                if !currentDescription.isEmpty {
                                    tempDescriptions.append(currentDescription.trimmingCharacters(in: .whitespacesAndNewlines))
                                    currentDescription = ""
                                }
                                let title = line.trimmingCharacters(in: .whitespacesAndNewlines)
                                tempTitles.append(title)
                            } else if !line.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                // This is part of a description
                                if !currentDescription.isEmpty {
                                    currentDescription += "\n\n"
                                }
                                currentDescription += line
                            }
                        }

                        // Append the last description if it exists
                        if !currentDescription.isEmpty {
                            tempDescriptions.append(currentDescription.trimmingCharacters(in: .whitespacesAndNewlines))
                        }
                        
                        print("Titles:", tempTitles)
                        print("Descriptions:", tempDescriptions)

                        self?.titles = tempTitles
                        self?.descriptions = tempDescriptions
                        self?.generateImagesForTitles()

                    case .failure(let error):
                        self?.response = "Error: \(error.localizedDescription)"
                    }
                }
            }
        }


    func analyzeImageAndUpdateUserInput(image: UIImage) {
        print("Went into the analyze function")
        self.isAnalyzingImage = true
        analyzeImage(image: image) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let description):
                    self?.userInput = description // Update userInput with the description
                    self?.sendMessage() // Send the message after analysis
                case .failure(let error):
                    print("Error analyzing image: \(error)")
                }
            }
        }
    }
    
    func analyzeImage(image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        let AIQuestionair = "Can you identify the type of object in the image. Just a 1 - 3 word answer is perfect. We require the result to pass it into another instance to get upcycling ideas for. If you can identify the materail the item is made of it will be perfect as well"
        let endpoint = "https://api.openai.com/v1/chat/completions"
        guard let url = URL(string: endpoint) else { return }
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }
        let base64Image = imageData.base64EncodedString()

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer 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", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let contentPart1: [String: Any] = ["type": "text", "text": AIQuestionair]
        let contentPart2: [String: Any] = ["type": "image_url", "image_url": ["url": "data:image/jpeg;base64,\(base64Image)"]]
        let message: [String: Any] = ["role": "user", "content": [contentPart1, contentPart2]]

        let body: [String: Any] = [
            "model": "gpt-4-vision-preview",
            "messages": [message],
            "max_tokens": 300
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)")
            }
            
            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                print("Raw Response: \(dataString)")
            }

            guard let data = data,
                  let jsonResponse = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let choices = jsonResponse["choices"] as? [[String: Any]],
                  let firstChoice = choices.first,
                  let message = firstChoice["message"] as? [String: Any],
                  let content = message["content"] as? String else {
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])))
                return
            }

            completion(.success(content))
        }.resume()
    }
    
    
}


