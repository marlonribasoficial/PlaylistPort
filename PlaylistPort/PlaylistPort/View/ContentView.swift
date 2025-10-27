//
//  ContentView.swift
//  PlaylistPort
//
//  Created by Marlon Ribas on 25/10/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = SpotifyViewModel()
    
    var body: some View {
        NavigationStack {
            if viewModel.accessToken == nil {
                VStack {
                    Button("Login com Spotify") {
                        viewModel.startLogin()
                    }
                    .padding()
                }
            } else {
                List(viewModel.playlists) { playlist in
                    NavigationLink(destination: PlaylistDetailView(viewModel: viewModel, playlist: playlist)) {
                        HStack(spacing: 16) {
                            URLToImageView(
                                coverURL: playlist.imageURL,
                                width: 60,
                                cornerRadius: 8
                            )
                            Text(playlist.name)
                                .font(.headline)
                            Spacer()
                            
                            if playlist.isLoadingTracks {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .green))
                                    .scaleEffect(1.2)
                                    .transition(.opacity.combined(with: .scale))
                                    .animation(.easeInOut(duration: 0.3), value: playlist.isLoadingTracks)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                .navigationTitle("Playlists")
            }
        }
        .onOpenURL { url in
            viewModel.handleSpotifyCallback(url: url)
        }
    }
}

#Preview {
    ContentView()
}
