//
//  SpotifyViewModel.swift
//  PlaylistPort
//
//  Created by Marlon Ribas on 25/10/25.
//

import Foundation
import Combine
import SwiftUI

class SpotifyViewModel: ObservableObject {
    @Published var playlists: [Playlist] = []
    @Published var accessToken: String?

    // MARK: - Login

    func startLogin() {
        startAuthFlow()
    }

    func handleCallbackWithToken(url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let code = components.queryItems?.first(where: { $0.name == "code" })?.value else {
            print("No code found in redirect URL")
            return
        }

        requestAccessToken(code: code) { token in
            self.accessToken = token
            self.fetchPlaylists()
        }
    }

    // MARK: - Playlists

    func fetchPlaylists() {
        guard let token = accessToken else { return }

        fetchUserPlaylists(accessToken: token) { playlists in
            DispatchQueue.main.async {
                self.playlists = playlists
                // Depois de carregar playlists, já podemos buscar as tracks
                self.loadAllPlaylistTracks()
            }
        }
    }

    // Carrega tracks de todas as playlists
    private func loadAllPlaylistTracks() {
        guard let token = accessToken else { return }

        for index in playlists.indices {
            let playlist = playlists[index]

            if playlist.isLikedSongs {
                fetchLikedSongs(accessToken: token) { tracks in
                    DispatchQueue.main.async {
                        self.playlists[index].tracks = tracks
                        self.playlists[index].totalTracks = tracks.count
                    }
                }
            } else {
                fetchPlaylistTracks(accessToken: token, playlistID: playlist.id) { tracks in
                    DispatchQueue.main.async {
                        self.playlists[index].tracks = tracks
                        self.playlists[index].totalTracks = tracks.count
                    }
                }
            }
        }
    }

    // MARK: - Carregamento de tracks de playlist específica

    func loadTracks(for playlist: Playlist) {
        guard let token = accessToken else { return }

        if let index = playlists.firstIndex(where: { $0.id == playlist.id }) {
            if playlist.isLikedSongs {
                fetchLikedSongs(accessToken: token) { tracks in
                    DispatchQueue.main.async {
                        self.playlists[index].tracks = tracks
                        self.playlists[index].totalTracks = tracks.count
                    }
                }
            } else {
                fetchPlaylistTracks(accessToken: token, playlistID: playlist.id) { tracks in
                    DispatchQueue.main.async {
                        self.playlists[index].tracks = tracks
                        self.playlists[index].totalTracks = tracks.count
                    }
                }
            }
        }
    }
}
