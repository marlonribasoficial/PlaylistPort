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
                        HStack {
                            URLToImageView(
                                coverURL: playlist.imageURL,
                                width: 60,
                                cornerRadius: 8
                            )
                            Text(playlist.name)
                                .font(.headline)
                            Spacer()
                        }
                    }
                }
                .navigationTitle("Playlists")
            }
        }
        .onOpenURL { url in
            viewModel.handleCallbackWithToken(url: url)
        }
    }
}

#Preview {
    ContentView()
}
