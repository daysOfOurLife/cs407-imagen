//
//  ContentView.swift
//  Imagen
//
//  Created by Victor Nguyen on 11/7/23.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        VStack(alignment: .center, spacing: 50) {
            
            title
                .padding(.top, 40)
            
            Spacer()
                
            
            newImageButton
            
            existingResultButton
        }
        .padding(.vertical, 100)
        .ignoresSafeArea()

    }
    
    private var title: some View {
        Text("Imagen")
            .font(.largeTitle)
            .bold()
    }
    
    private var newImageButton: some View {
        Button {
            // TODO: Implement
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 10.0)
                    .frame(width: 250, height: 60)
                Text("New Image")
                    .foregroundStyle(.background)
            }
        }
    }
    
    private var existingResultButton: some View {
        Button {
            // TODO: Implement
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 10.0)
                    .frame(width: 250, height: 60)
                Text("Existing Result")
                    .foregroundStyle(.background)
            }
        }
    }
}

#Preview {
    HomeView()
}
