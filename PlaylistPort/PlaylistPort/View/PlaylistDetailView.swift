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
        Form {
            Section {
                PlaylistInfoView(playlist: playlist)
            }
            Section {
                List(playlist.tracks) { track in
                    HStack(spacing: 16) {
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
        }
        .onAppear {
            if !playlist.isLikedSongs && playlist.tracks.isEmpty {
                viewModel.loadTracks(for: playlist)
            }
        }
        .background(playlist.primaryColor ?? Color.clear)
    }
}
