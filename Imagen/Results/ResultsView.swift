//
//  ResultsView.swift
//  Imagen
//
//  Created by Victor Nguyen on 11/15/23.
//

import SwiftUI

struct ResultsView: View {
    // MARK: Properties

    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = ChatGPTViewModel(chatService: ChatGPTService(apiKey: "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")) // Replace with your actual API key
    private var capturedImage: UIImage?

    // MARK: Initializers

    init(capturedImage: UIImage?) {
        self.capturedImage = capturedImage
        _viewModel = StateObject(wrappedValue: ChatGPTViewModel(chatService: ChatGPTService(apiKey: "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")))
        print("Image in ResultsView init:", capturedImage != nil ? "Valid" : "Nil")
    }

    // MARK: Body

    var body: some View {
        VStack {
            if viewModel.isAnalyzingImage {
                FallingLeafAnimationView()
                    .frame(maxHeight: .infinity)
                    .padding()
            } else {
                VStack(alignment: .leading, spacing: 8.0) {
                    Text("Detected:")
                        .font(Font.system(size: 24.0, weight: .bold, design: .monospaced))
                    
                    HStack {
                        TextField("Unleash your creativity...", text: $viewModel.userInput)
                            .textFieldStyle(.roundedBorder)
                            .font(Font.system(size: 14.0, weight: .semibold, design: .monospaced))
                        
                        Button {
                            viewModel.sendMessage()
                            viewModel.userInput = "" // Clear the text field after sending
                        } label: {
                            Image(systemName: "arrow.counterclockwise.circle")
                                .scaleEffect(1.25)
                                .foregroundStyle(.green)
                        }
                        
                    }
                    .foregroundStyle(.gray)
                    
                    Text("Edit above if something's not quite right.")
                        .font(Font.system(size: 13.5, weight: .regular, design: .monospaced))
                        .foregroundStyle(.gray)

                }
                .padding()

                // Paginated View
                TabView {
                    ForEach(Array(zip(viewModel.titles.indices, viewModel.titles)), id: \.0) { index, title in
                        VStack {

                            Text(title)
                                .font(Font.system(size: 16.0, weight: .bold, design: .monospaced))

                            if viewModel.imageUrls.indices.contains(index) {
                                let imageUrl = viewModel.imageUrls[index]
                                AsyncImage(url: imageUrl) { imagePhase in
                                    switch imagePhase {
                                    case .empty:
                                        ProgressView()
                                    case let .success(image):
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
                                .padding(.vertical)
                            }

                            if viewModel.descriptions.indices.contains(index) {
                                Text(viewModel.descriptions[index])
                                    .font(Font.system(size: 14.0, weight: .light, design: .monospaced))
                            }
                        }
                        .padding()
                        .padding(.bottom, 50)
                    }
                }
                .tabViewStyle(PageTabViewStyle()) // Enables swiping
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always)) // Show page indicators
            }
        }
        .navigationBarBackButtonHidden()
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            if !viewModel.isAnalyzingImage {
                ToolbarItem(placement: .principal) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Results")
                            .font(Font.system(size: 18.0, weight: .semibold, design: .monospaced))
                            .tint(.primary)
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "leaf")
                            .resizable()
                            .scaledToFit()
                            .bold()
                            .tint(.primary)
                    }
                }
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

// MARK: Subviews

struct LeafImageView: View {
    let swayRange: CGFloat

    var body: some View {
        Image("leaf5")
            .resizable()
            .scaledToFit()
            .frame(width: 60, height: 60)
    }

    init() {
        swayRange = CGFloat.random(in: -30...30)
    }
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

struct FallingLeafAnimationView: View {
    let numberOfLeaves: Int = 10
    let minDuration: Double = 8   // Minimum duration for fall
    let maxDuration: Double = 15  // Maximum duration for fall

    @State private var positions: [CGPoint] = []
    @State private var durations: [Double] = []

    var body: some View {
        ZStack {
            GeometryReader { geometry in
                ForEach(0..<numberOfLeaves, id: \.self) { index in
                    LeafImageView()
                        .position(x: positions.count > index ? positions[index].x : geometry.size.width / 2,
                                  y: positions.count > index ? positions[index].y : -50)
                        .onAppear {
                            withAnimation(
                                Animation.linear(duration: durations.count > index ? durations[index] : 10)
                                    .repeatForever(autoreverses: false)
                                    .delay(Double.random(in: 0...2))
                            ) {
                                if positions.count > index {
                                    positions[index] = CGPoint(x: CGFloat.random(in: 20...geometry.size.width - 20),
                                                               y: geometry.size.height + 50)
                                }
                            }
                        }
                }
            }
            
            // Loading Text
            Text("Loading your generated options ...")
                .font(.title) // Adjusted to a smaller, more elegant font
                .fontWeight(.semibold)
                .foregroundColor(.white)
        }
        .onAppear {
            for _ in 0..<numberOfLeaves {
                positions.append(CGPoint(x: CGFloat.random(in: 20...UIScreen.main.bounds.width - 20),
                                         y: CGFloat.random(in: -100...0)))
                durations.append(Double.random(in: minDuration...maxDuration))
            }
        }
    }
}

// MARK: Previews


struct LeafShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        // Drawing a simple leaf shape
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addQuadCurve(to: CGPoint(x: rect.minX, y: rect.midY),
                          control: CGPoint(x: rect.minX, y: rect.minY))
        path.addQuadCurve(to: CGPoint(x: rect.midX, y: rect.maxY),
                          control: CGPoint(x: rect.width * 0.25, y: rect.height * 0.75))
        path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.midY),
                          control: CGPoint(x: rect.width * 0.75, y: rect.height))
        path.addQuadCurve(to: CGPoint(x: rect.midX, y: rect.minY),
                          control: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()

        return path
    }
}


