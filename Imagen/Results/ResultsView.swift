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
                .font(Font.system(size: 16.0, weight: .semibold, design: .monospaced))
                .foregroundStyle(.green)
                .padding()

                // Paginated View
                TabView {
                    ForEach(Array(zip(viewModel.titles.indices, viewModel.titles)), id: \.0) { index, title in
                        VStack {
                            Spacer()

                            Text(title)
                                .font(Font.system(size: 16.0, weight: .bold, design: .monospaced))
                                .padding(.vertical)

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
                ToolbarItem(placement: .topBarLeading) {
                    HStack {
                        Spacer()
                        Button {
                            dismiss()
                        } label: {
                            Image("icon_transparent")
                                .resizable()
                                .scaledToFit()
                                .scaleEffect(1.75)
                                .foregroundStyle(.black)
                        }
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
            ForEach(0 ..< numberOfLeaves, id: \.self) { _ in
                LeafView()
                    .position(x: CGFloat.random(in: 0 ... geometry.size.width), y: start ? geometry.size.height + 20 : -20)
                    .animation(
                        Animation.linear(duration: duration)
                            .repeatForever(autoreverses: false)
                            .delay(Double.random(in: 0 ... 2)),
                        value: start
                    )
            }
        }
        .onAppear {
            start = true
        }
    }
}

// MARK: Previews

#Preview {
    ResultsView(capturedImage: UIImage(named: "exampleImage"))
}
