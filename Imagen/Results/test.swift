//
//  ResultsView.swift
//  Imagen
//
//  Created by Victor Nguyen on 11/15/23.
//

import SwiftUI

struct TestView: View {
    @StateObject private var viewModel = ChatGPTViewModel(chatService: ChatGPTService(apiKey: "API-KEY")) // Replace with your actual API key
    private var capturedImage: UIImage?
    
    init(capturedImage: UIImage?) {
        self.capturedImage = capturedImage
        _viewModel = StateObject(wrappedValue: ChatGPTViewModel(chatService: ChatGPTService(apiKey: "API-KEY")))
    }
    
    var body: some View {
        GeometryReader { geometry in // Use GeometryReader to get full screen height
            VStack {
                if viewModel.isAnalyzingImage {
                    ZStack {
                        FallingLeafAnimationView()
                            .frame(maxHeight: .infinity)
                        Text("Loading your generated options")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.7))
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    }
                } else {
                    TabView {
                        ForEach(Array(zip(viewModel.titles.indices, viewModel.titles)), id: \.0) { index, title in
                            VStack {
                                Text(title)
                                    .fontWeight(.bold)
                                    .padding()
                                
                                if viewModel.imageUrls.indices.contains(index) {
                                    let imageUrl = viewModel.imageUrls[index]
                                    AsyncImage(url: imageUrl) { imagePhase in
                                        switch imagePhase {
                                        case .empty:
                                            ProgressView()
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                        case .failure:
                                            Image(systemName: "photo")
                                        @unknown default:
                                            EmptyView()
                                        }
                                    }
                                    .frame(width: 200, height: 200)
                                    .cornerRadius(8)
                                    .shadow(radius: 3)
                                }
                                
                                ScrollView(.vertical, showsIndicators: true) {
                                    Text(viewModel.descriptions[index])
                                        .padding()
                                }
                                .frame(maxHeight: .infinity) // ScrollView will take up the remaining height
                            }
                            .padding(.horizontal)
                            .frame(width: geometry.size.width, height: geometry.size.height) // Make VStack take full height
                            .clipped()
                        }
                    }
                    .tabViewStyle(PageTabViewStyle())
                    .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height) // Make VStack take full height
        }
        .onAppear {
            if let image = capturedImage {
                viewModel.analyzeImageAndUpdateUserInput(image: image)
            }
        }
        .background(Color.green.opacity(0.1))
    }
}

#Preview {
    ResultsView(capturedImage: UIImage(named: "exampleImage"))
}

//struct FallingLeafAnimationView: View {
//    let numberOfLeaves: Int = 15
//    let minDuration: Double = 8   // Minimum duration for fall
//    let maxDuration: Double = 15  // Maximum duration for fall
//
//    @State private var positions: [CGPoint] = []
//    @State private var durations: [Double] = []
//
//    var body: some View {
//        GeometryReader { geometry in
//            ForEach(0..<numberOfLeaves, id: \.self) { index in
//                LeafImageView()
//                    .position(x: positions.count > index ? positions[index].x : geometry.size.width / 2,
//                              y: positions.count > index ? positions[index].y : -50)
//                    .onAppear {
//                        withAnimation(
//                            Animation.linear(duration: durations.count > index ? durations[index] : 10)
//                                .repeatForever(autoreverses: false)
//                                .delay(Double.random(in: 0...2))
//                        ) {
//                            if positions.count > index {
//                                positions[index] = CGPoint(x: CGFloat.random(in: 20...geometry.size.width - 20),
//                                                           y: geometry.size.height + 50)
//                            }
//                        }
//                    }
//            }
//        }
//        .onAppear {
//            // Initialize positions and durations for all leaves
//            for _ in 0..<numberOfLeaves {
//                positions.append(CGPoint(x: CGFloat.random(in: 20...UIScreen.main.bounds.width - 20),
//                                         y: CGFloat.random(in: -100...0)))
//                durations.append(Double.random(in: minDuration...maxDuration))
//            }
//        }
//    }
//}



