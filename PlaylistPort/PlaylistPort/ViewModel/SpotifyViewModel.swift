//
//  SpotifyViewModel.swift
//  PlaylistPort
//
//  Created by Marlon Ribas on 25/10/25.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class SpotifyViewModel: ObservableObject {
    @Published var playlists: [Playlist] = []
    @Published var accessToken: String? = nil

    private let tokenKey = "spotify_access_token"

    init() {
        if let token = loadTokenFromKeychain() {
            self.accessToken = token
            self.fetchPlaylists()
        }
    }

    // MARK: - Keychain Helpers
    private func saveTokenToKeychain(_ token: String) {
        let data = token.data(using: .utf8)!

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: tokenKey,
            kSecValueData as String: data
        ]

        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }

    private func loadTokenFromKeychain() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: tokenKey,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)

        if status == errSecSuccess,
           let data = dataTypeRef as? Data,
           let token = String(data: data, encoding: .utf8) {
            return token
        }
        return nil
    }

    // MARK: - Login
    func startLogin() {
        SpotifyAuth.startAuthFlow()
    }

    func handleSpotifyCallback(url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let code = components.queryItems?.first(where: { $0.name == "code" })?.value else {
            print("No code found in callback URL")
            return
        }

        SpotifyAuth.requestAccessToken(code: code) { token in
            DispatchQueue.main.async {
                self.accessToken = token
                self.saveTokenToKeychain(token)
                self.fetchPlaylists()
            }
        }
    }

    // MARK: - Playlists
    func fetchPlaylists() {
        guard let token = accessToken else { return }

        SpotifyAuth.fetchUserPlaylists(accessToken: token) { playlists in
            DispatchQueue.main.async {
                self.playlists = playlists
                self.loadAllPlaylistTracks()
            }
        }
    }

    // Carrega tracks de todas as playlists
    private func loadAllPlaylistTracks() {
        guard let token = accessToken else { return }

        for index in playlists.indices {
            playlists[index].isLoadingTracks = true
            let playlist = playlists[index]

            if playlist.isLikedSongs {
                SpotifyAuth.fetchLikedSongs(accessToken: token) { tracks in
                    DispatchQueue.main.async {
                        self.playlists[index].tracks = tracks
                        self.playlists[index].totalTracks = tracks.count
                        self.playlists[index].isLoadingTracks = false
                    }
                }
            } else {
                SpotifyAuth.fetchPlaylistTracks(accessToken: token, playlistID: playlist.id) { tracks in
                    DispatchQueue.main.async {
                        self.playlists[index].tracks = tracks
                        self.playlists[index].totalTracks = tracks.count
                        self.playlists[index].isLoadingTracks = false
                    }
                }
            }
        }
    }

    // MARK: - Carregamento de tracks de playlist específica
    func loadTracks(for playlist: Playlist) {
        guard let token = accessToken else { return }

        if let index = playlists.firstIndex(where: { $0.id == playlist.id }) {
            playlists[index].isLoadingTracks = true

            if playlist.isLikedSongs {
                SpotifyAuth.fetchLikedSongs(accessToken: token) { tracks in
                    DispatchQueue.main.async {
                        self.playlists[index].tracks = tracks
                        self.playlists[index].totalTracks = tracks.count
                        self.playlists[index].isLoadingTracks = false
                    }
                }
            } else {
                SpotifyAuth.fetchPlaylistTracks(accessToken: token, playlistID: playlist.id) { tracks in
                    DispatchQueue.main.async {
                        self.playlists[index].tracks = tracks
                        self.playlists[index].totalTracks = tracks.count
                        self.playlists[index].isLoadingTracks = false
                    }
                }
            }
        }
    }
}
