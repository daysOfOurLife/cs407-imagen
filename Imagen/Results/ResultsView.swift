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
    @StateObject private var viewModel = ChatGPTViewModel(chatService: ChatGPTService(apiKey: "API-KEY-CANNOT-BE-PUSHED-AS-IT-GETS-DISABLED")) // Replace with your actual API key
    private var capturedImage: UIImage?

    // MARK: Initializers

    init(capturedImage: UIImage?) {
        self.capturedImage = capturedImage
        _viewModel = StateObject(wrappedValue: ChatGPTViewModel(chatService: ChatGPTService(apiKey: "API-KEY-CANNOT-BE-PUSHED-AS-IT-GETS-DISABLED")))
        print("Image in ResultsView init:", capturedImage != nil ? "Valid" : "Nil")
    }

    // MARK: Body

    var body: some View {
        GeometryReader { geometry in
            VStack {
                if viewModel.isAnalyzingImage {
                    loadingView
                } else {
                    heading

                    paginatedView
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
            .frame(width: geometry.size.width, height: geometry.size.height)
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
    
    // MARK: Subviews

    private var loadingView: some View {
        ZStack {
            FallingLeafAnimationView()
                .frame(maxHeight: .infinity)
            Text("Loading your generated options")
                .font(Font.system(size: 16.0, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
                .padding()
                .background(Color.black.opacity(0.7))
                .cornerRadius(10)
                .shadow(radius: 5)
        }
        .background(.green)
    }

    private var heading: some View {
        VStack(alignment: .leading, spacing: 8.0) {
            Text("Detected:")
                .font(Font.system(size: 24.0, weight: .bold, design: .monospaced))

            HStack {
                TextField("Unleash your creativity...", text: $viewModel.userInput)
                    .textFieldStyle(.roundedBorder)
                    .font(Font.system(size: 14.0, weight: .semibold, design: .monospaced))
                    .foregroundStyle(.green)

                Button {
                    viewModel.isAnalyzingImage = true
                    viewModel.sendMessage()
                    viewModel.userInput = "" // Clear the text field after sending
                } label: {
                    Image(systemName: "arrow.counterclockwise.circle")
                        .scaleEffect(1.25)
                        .foregroundStyle(.green)
                }
            }

            Text("Edit above if something's not quite right.")
                .font(Font.system(size: 13.5, weight: .regular, design: .monospaced))
                .foregroundStyle(.gray)
        }
        .padding()
    }

    private var paginatedView: some View {
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
                        .cornerRadius(8)
                        .shadow(radius: 3)
                        .padding(.vertical)
                    }

                    ScrollView {
                        Text(viewModel.descriptions[index])
                            .font(Font.system(size: 14.0, weight: .light, design: .monospaced))
                    }
                    .frame(maxHeight: .infinity)
                }
                .padding()
                .padding(.bottom, 50)
            }
        }
        .tabViewStyle(PageTabViewStyle()) // Enables swiping
        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always)) // Show page indicators
    }
}

// MARK: Subviews

struct FallingLeafAnimationView: View {
    let numberOfLeaves: Int = 10
    let minDuration: Double = 8
    let maxDuration: Double = 15
    let leafImageNames = ["leaf2", "leaf3"]

    @State private var positions: [CGPoint] = []
    @State private var durations: [Double] = []

    init() {
        // Initialize positions off-screen at the top and durations
        _positions = State(initialValue: (0 ..< numberOfLeaves).map { _ in
            CGPoint(x: CGFloat.random(in: 20 ... UIScreen.main.bounds.width - 20),
                    y: -100) // Start slightly above the top of the screen
        })
        _durations = State(initialValue: (0 ..< numberOfLeaves).map { _ in
            Double.random(in: minDuration ... maxDuration)
        })
    }

    var body: some View {
        GeometryReader { geometry in
            ForEach(0 ..< numberOfLeaves, id: \.self) { index in
                LeafImageView(imageName: leafImageNames.randomElement() ?? "leaf")
                    .position(x: positions[index].x, y: positions[index].y)
                    .onAppear {
                        withAnimation(getAnimation(for: index)) {
                            positions[index].y = geometry.size.height + 50 // Animate to fall off the bottom of the screen
                        }
                    }
            }
        }
    }

    private func getAnimation(for index: Int) -> Animation {
        Animation.linear(duration: durations[index])
            .repeatForever(autoreverses: false)
            .delay(Double.random(in: 0 ... 2))
    }
}

struct LeafImageView: View {
    let imageName: String

    var body: some View {
        Image(imageName)
            .resizable()
            .scaledToFit()
            .frame(width: 60, height: 60)
    }
}

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

#Preview {
    ResultsView(capturedImage: UIImage(named: "exampleImage"))
}
