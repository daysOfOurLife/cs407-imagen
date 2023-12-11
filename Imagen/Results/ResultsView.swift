//
//  ResultsView.swift
//  Imagen
//
//  Created by Victor Nguyen on 11/15/23.
//

import SwiftUI

struct ResultsView: View {
//    var body: some View {
//        VStack {
//            Text("Results")
//        }
    
//    }
    
    @StateObject private var viewModel = ChatGPTViewModel(chatService: ChatGPTService(apiKey: "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")) // Replace with your actual API key
    private var capturedImage: UIImage?
    
    init(capturedImage: UIImage?) {
        self.capturedImage = capturedImage
        _viewModel = StateObject(wrappedValue: ChatGPTViewModel(chatService: ChatGPTService(apiKey: "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")))
        print("Image in ResultsView init:", capturedImage != nil ? "Valid" : "Nil")
    }
    
    var body: some View {
    
        VStack {
            if viewModel.isAnalyzingImage {
                FallingLeavesView()
                    .frame(height: 300)
                    .padding()
            } else {
                TextField("Type your message here", text: $viewModel.userInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Button("This is not used") {
                    viewModel.sendMessage()
                    viewModel.userInput = "" // Clear the text field after sending
                }
                .padding()
                
                // Paginated View
                TabView {
                    ForEach(Array(zip(viewModel.titles.indices, viewModel.titles)), id: \.0) { index, title in
                        VStack {
                            Text(title)
                                .fontWeight(.bold)
                                .padding(.top)
                            
                            if viewModel.imageUrls.indices.contains(index) {
                                let imageUrl = viewModel.imageUrls[index]
                                AsyncImage(url: imageUrl) { imagePhase in
                                    switch imagePhase {
                                    case .empty:
                                        ProgressView()
                                            .frame(width: 200, height: 200)
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 200, height: 200)
                                    case .failure:
                                        Image(systemName: "photo")
                                            .frame(width: 200, height: 200)
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                            }
                            
                            if viewModel.descriptions.indices.contains(index) {
                                Text(viewModel.descriptions[index])
                            }
                        }
                        .padding()
                    }
                }
                .tabViewStyle(PageTabViewStyle()) // Enables swiping
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always)) // Show page indicators
            }
        }
        .onAppear {
            if let image = capturedImage {
                print("Image is present, calling analyze function")
                viewModel.analyzeImageAndUpdateUserInput(image: image)
            } else {
                print("No image found")
            }
        }
    }
}

#Preview {
    ResultsView(capturedImage: UIImage(named: "exampleImage"))
}

struct LeafView: View {
    var body: some View {
        Circle()
            .frame(width: 10, height: 10)
            .foregroundColor(.green)
    }
}

struct FallingLeavesView: View {
    @State private var start = false

    let numberOfLeaves = 10
    let duration: Double = 5

    var body: some View {
        GeometryReader { geometry in
            ForEach(0..<numberOfLeaves, id: \.self) { index in
                LeafView()
                    .position(x: CGFloat.random(in: 0...geometry.size.width), y: start ? geometry.size.height + 20 : -20)
                    .animation(
                        Animation.linear(duration: duration)
                            .repeatForever(autoreverses: false)
                            .delay(Double.random(in: 0...2)),
                        value: start
                    )
            }
        }
        .onAppear {
            start = true
        }
    }
}


