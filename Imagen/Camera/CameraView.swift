//
//  Imagen
//
//  Created by Victor Nguyen on 11/15/23.
//

import SwiftUI

struct CameraView: View {
    @State private var viewModel = ViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                ViewfinderView(image: $viewModel.viewfinderImage)
                    .task {
                        await viewModel.camera.start()
                        await viewModel.loadPhotos()
                        await viewModel.loadThumbnail()
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
        }
        .onAppear() {
            viewModel.camera.isPhotoTaken = false
        }
    }

    // MARK: Subviews

    private var buttonStack: some View {
        HStack {
            if viewModel.camera.isPhotoTaken {
                retakePhotoButton
                
                Spacer()

                upcycleButton
            } else {
                takePhotoButton
            }
        }
        .buttonStyle(.plain)
        .labelStyle(.iconOnly)
        .padding(.horizontal)
    }

    private var retakePhotoButton: some View {
        Button {
            viewModel.camera.retakePhoto()
        } label: {
            Image(systemName: "arrow.triangle.2.circlepath.camera")
                .foregroundStyle(.black)
                .padding()
                .background(Color.white)
                .clipShape(Circle())
        }
    }

    private var takePhotoButton: some View {
        Button {
            viewModel.camera.takePhoto()
        } label: {
            Label {
                Text("Take Photo")
            } icon: {
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
    }

    private var upcycleButton: some View {
        Button {
            // TODO: Save image and send to API
        } label: {
            Text("Upcycle")
                .foregroundStyle(.black)
                .fontWeight(.semibold)
                .padding(.vertical, 10)
                .padding(.horizontal, 20)
                .background(Color.white)
                .clipShape(Capsule())
        }
    }
}

#Preview {
    CameraView()
}
