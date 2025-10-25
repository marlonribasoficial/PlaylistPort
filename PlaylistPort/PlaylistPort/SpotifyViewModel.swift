//
//  SpotifyViewModel.swift
//  PlaylistPort
//
//  Created by Marlon Ribas on 25/10/25.
//

import Foundation
import Combine

class SpotifyViewModel: ObservableObject {
    @Published var playlists: [Playlist] = []
    @Published var accessToken: String?

    // inicia login
    func startLogin() {
        startAuthFlow()
    }

    // lida com o callback do Spotify e atualiza ViewModel
    func handleCallbackWithToken(url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let code = components.queryItems?.first(where: { $0.name == "code" })?.value else {
            print("No code found in redirect URL")
            return
        }
        
        print("Authorization Code: \(code)")

        // chama a função do SpotifyAuth e recebe o token
        requestAccessToken(code: code) { token in
            self.accessToken = token
            self.fetchPlaylists()
        }
    }

    // busca playlists usando o token
    func fetchPlaylists() {
        guard let token = accessToken else { return }
        fetchUserPlaylists(accessToken: token) { playlists in
            DispatchQueue.main.async {
                self.playlists = playlists
            }
        }
    }
}
