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
        NavigationView {
            VStack {
                if viewModel.accessToken == nil {
                    Button("Login com Spotify") {
                        viewModel.startLogin()
                    }
                    .padding()
                } else {
                    List {
                        ForEach(viewModel.playlists) { playlist in
                            HStack {
                                PlaylistCoverView(
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
                    .navigationTitle("Minhas Playlists 🎶")
                }
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
