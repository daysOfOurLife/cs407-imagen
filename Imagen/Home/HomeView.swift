//
//  ContentView.swift
//  Imagen
//
//  Created by Victor Nguyen on 11/7/23.
//

import SwiftUI

struct HomeView: View {
    // MARK: Properties

    // MARK: Body

    var body: some View {
        GeometryReader { proxy in
            NavigationStack {
                ZStack {
                    logoArt(proxy: proxy)

                    VStack(alignment: .leading, spacing: 0.0) {
                        title
                        subTitle

                        newImageButton

                        // TODO: Show only if user has existing result
//                        existingResultButton
                    }
                    .padding(.top, 100.0)
                    .frame(maxWidth: proxy.size.width * 0.6)
                }
            }
            .tint(.green)
        }
    }

    // MARK: Subviews

    private func logoArt(proxy: GeometryProxy) -> some View {
        Group {
            Rectangle()
                .frame(height: 2)
                .tint(.primary)

            Image("icon_transparent")
                .resizable()
                .scaledToFit()
                .frame(width: 150)
                .offset(x: proxy.size.width / 4.25, y: -35)
                .tint(.primary)
        }
        .offset(y: -(proxy.size.height / 4.25))
    }

    private var title: some View {
        Text("Imagen")
            .font(Font.system(size: 40.0, weight: .bold, design: .monospaced))
    }

    private var subTitle: some View {
        Text("Upcycling powered by AI.")
            .font(Font.system(.subheadline, design: .monospaced, weight: .light))
            .padding(.leading, 2.5)
            .padding(.bottom, 70.0)
    }

    private var newImageButton: some View {
        NavigationLink {
            CameraView()
        } label: {
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 10.0)
                    .foregroundStyle(.green)
                    .frame(height: 60)
                Text("New Image")
                    .font(Font.system(size: 16.0, weight: .semibold, design: .monospaced))
                    .foregroundStyle(.background)
                    .padding(.leading)
            }
            .padding(.bottom, 30.0)
        }
    }

    private var existingResultButton: some View {
        NavigationLink {
           // ResultsView()
        } label: {
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 10.0)
                    .frame(height: 60.0)
                    .foregroundStyle(.gray)
                Text("Existing Result")
                    .font(Font.system(size: 16.0, weight: .semibold, design: .monospaced))
                    .foregroundStyle(.background)
                    .padding(.leading)
            }
        }
    }
}

#Preview {
    HomeView()
}
