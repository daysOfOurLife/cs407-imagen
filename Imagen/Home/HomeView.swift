//
//  ContentView.swift
//  Imagen
//
//  Created by Victor Nguyen on 11/7/23.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack {
            VStack(alignment: .center, spacing: 50) {
                title
                    .padding(.top, 40)
                
                Spacer()
                
                newImageButton
                
                // TODO: Show only if user has existing result
                existingResultButton
            }
            .padding(.vertical, 100)
            .ignoresSafeArea()
        }
    }

    private var title: some View {
        Text("Imagen")
            .font(.largeTitle)
            .bold()
    }

    private var newImageButton: some View {
        NavigationLink {
            CameraView()
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 10.0)
                    .frame(width: 250, height: 60)
                Text("New Image")
                    .bold()
                    .foregroundStyle(.background)
            }
        }
    }

    private var existingResultButton: some View {
        NavigationLink {
            ResultsView()
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 10.0)
                    .frame(width: 250, height: 60)
                Text("Existing Result")
                    .bold()
                    .foregroundStyle(.background)
            }
        }
    }
}

#Preview {
    HomeView()
}
