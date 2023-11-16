//
//  Imagen
//
//  Created by Victor Nguyen on 11/15/23.
//

import SwiftUI

struct CameraView: View {
    @State private var viewModel = ViewModel()

    private static let barHeightFactor = 0.175

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ViewfinderView(image: $viewModel.viewfinderImage)
                    .overlay(alignment: .top) {
                        Color.black
                            .opacity(0.75)
                            .frame(height: geometry.size.height * Self.barHeightFactor)
                    }
                    .overlay(alignment: .center) {
                        Color.clear
                            .frame(height: geometry.size.height * (1 - (Self.barHeightFactor * 2)))
                            .accessibilityElement()
                            .accessibilityLabel("View Finder")
                            .accessibilityAddTraits([.isImage])
                    }
                    .overlay(alignment: .bottom) {
                        buttonsView()
                            .frame(height: geometry.size.height * Self.barHeightFactor)
                            .background(.black.opacity(0.75))
                    }
                    .background(.black)
            }
            .task {
                await viewModel.camera.start()
                await viewModel.loadPhotos()
                await viewModel.loadThumbnail()
            }
            .navigationBarTitleDisplayMode(.inline)
            .ignoresSafeArea()
            .statusBar(hidden: true)
        }
    }

    private func buttonsView() -> some View {
        HStack(spacing: 60) {
            Spacer()

            NavigationLink {
                PhotoCollectionView(photoCollection: viewModel.photoCollection)
                    .onAppear {
                        viewModel.camera.isPreviewPaused = true
                    }
                    .onDisappear {
                        viewModel.camera.isPreviewPaused = false
                    }
            } label: {
                Label {
                    Text("Gallery")
                } icon: {
                    ThumbnailView(image: viewModel.thumbnailImage)
                }
            }

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

            Button {
                viewModel.camera.switchCaptureDevice()
            } label: {
                Label("Switch Camera", systemImage: "arrow.triangle.2.circlepath")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
            }

            Spacer()
        }
        .buttonStyle(.plain)
        .labelStyle(.iconOnly)
        .padding()
        .padding(.bottom, 25.0)
    }
}
