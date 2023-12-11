//
//  Imagen
//
//  Created by Victor Nguyen on 11/15/23.
//

import SwiftUI

struct CameraView: View {
    // MARK: Properties

    @State private var viewModel = ViewModel()

    // MARK: Body

    var body: some View {
        ZStack {
            ViewfinderView(image: $viewModel.viewfinderImage)
                .task {
                    await viewModel.camera.start()
                }
                .navigationBarTitleDisplayMode(.inline)
                .ignoresSafeArea()
                .statusBar(hidden: true)

            VStack {
                Spacer()
                buttonStack
            }
        }
        .background(.black)
        .onAppear {
            viewModel.camera.isPhotoTaken = false
        }
    }

    // MARK: Subviews

    private var buttonStack: some View {
        HStack {
            if !viewModel.camera.isPhotoTaken {
                takePhotoButton
            } else {
                HStack(spacing: 25) {
                    Spacer()
                    retakePhotoButton

                    Spacer()

                    upcycleButton
                    Spacer()
                }
            }
        }
        .padding(.bottom, 20)
        .frame(height: 100)
    }

    private var retakePhotoButton: some View {
        Button {
            viewModel.camera.retakePhoto()
        } label: {
            VStack {
                Text("Retake")
                    .font(Font.system(size: 14.0, weight: .semibold, design: .monospaced))
                    .foregroundStyle(.white)

                
                ZStack {
                    Capsule()
                        .foregroundStyle(.white)
                        .frame(width: 70, alignment: .center)
                    Image(systemName: "gobackward")
                        .fontWeight(.light)
                        .scaleEffect(1.3)
                        .foregroundStyle(.black)
                }
                
            }
        }
    }

    private var takePhotoButton: some View {
        Button {
            viewModel.camera.takePhoto()
        } label: {
            ZStack {
                Circle()
                    .strokeBorder(.white, lineWidth: 3)
                    .frame(width: 72, height: 72)
                Circle()
                    .fill(.white)
                    .frame(width: 60, height: 60)
            }
        }
    }

    private var upcycleButton: some View {
        NavigationLink {
            // Check if the UIImage can be created from photoData
            if let uiImage = UIImage(data: viewModel.camera.photoData) {
                // Pass the uiImage to ResultsView
                ResultsView(capturedImage: uiImage)
            } else {
                // Handle the case where the image could not be created
                Text("Oops! There was an error capturing the image. Please try again.")
            }
        } label: {
            VStack {
                Text("Upcycle")
                    .font(Font.system(size: 14.0, weight: .semibold, design: .monospaced))
                    .foregroundStyle(.green)

                ZStack {
                    Capsule()
                        .foregroundStyle(.green)
                        .frame(width: 70, alignment: .center)
                    Image("icon_transparent")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(.black)
                        .scaleEffect(1.25)
                }
            }
        }
    }
}

#Preview {
    CameraView()
}
