//
//  PlaylistDetailView.swift
//  PlaylistPort
//
//  Created by Marlon Ribas on 25/10/25.
//

import SwiftUI

struct PlaylistDetailView: View {
    @ObservedObject var viewModel: SpotifyViewModel
    let playlist: Playlist
    
    var body: some View {
        VStack {
            URLToImageView(
                coverURL: playlist.imageURL,
                width: 200,
                cornerRadius: 16
            )
            
            Text(playlist.name)
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            
            List(playlist.tracks) { track in
                HStack(spacing: 8) {
                    URLToImageView(
                        coverURL: track.imageURL,
                        width: 50,
                        cornerRadius: 6
                    )
                    
                    VStack(alignment: .leading) {
                        Text(track.title)
                            .font(.headline)
                        Text(track.artist)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .onAppear {
            viewModel.loadTracks(for: playlist)
        }
    }
}
