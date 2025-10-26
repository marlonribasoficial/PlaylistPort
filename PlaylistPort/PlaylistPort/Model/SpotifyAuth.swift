//
//  SpotifyAuth.swift
//  PlaylistPort
//
//  Created by Marlon Ribas on 25/10/25.
//

import CommonCrypto
import Foundation
import UIKit
import SwiftUI

var currentCodeVerifier: String?

func generateCodeVerifier() -> String {
    let length = 64
    let characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~"
    var result = ""
    for _ in 0..<length {
        result.append(characters.randomElement()!)
    }
    return result
}

func generateCodeChallenge(codeVerifier: String) -> String {
    guard let data = codeVerifier.data(using: .utf8) else {
        return ""
    }
    
    var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
    data.withUnsafeBytes {
        _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &digest)
    }
    
    let sha256Data = Data(digest)
    
    return sha256Data
        .base64EncodedString()
        .replacingOccurrences(of: "+", with: "-")
        .replacingOccurrences(of: "/", with: "_")
        .replacingOccurrences(of: "=", with: "")
}

func startAuthFlow() {
    let clientID = "e5f37995edd34160a1186d8354113d67"
    let redirectURI = "playlistport://callback"
    let scopes = "user-library-read playlist-read-private playlist-read-collaborative"
    
    let codeVerifier = generateCodeVerifier()
    currentCodeVerifier = codeVerifier
    let codeChallenge = generateCodeChallenge(codeVerifier: codeVerifier)
    
    let authURLString = "https://accounts.spotify.com/authorize?response_type=code&client_id=\(clientID)&scope=\(scopes)&redirect_uri=\(redirectURI)&code_challenge_method=S256&code_challenge=\(codeChallenge)"
    
    guard let url = URL(string: authURLString) else { return }
    
    UIApplication.shared.open(url) // isso abre o Safari
}

func requestAccessToken(code: String, completion: @escaping (String) -> Void) {
    guard let codeVerifier = currentCodeVerifier else {
        print("No code verifier available")
        return
    }
    
    let clientID = "e5f37995edd34160a1186d8354113d67"
    let redirectURI = "playlistport://callback"
    let tokenURL = URL(string: "https://accounts.spotify.com/api/token")!
    
    var request = URLRequest(url: tokenURL)
    request.httpMethod = "POST"
    
    let bodyParams = [
        "grant_type": "authorization_code",
        "code": code,
        "redirect_uri": redirectURI,
        "client_id": clientID,
        "code_verifier": codeVerifier
    ]
    
    request.httpBody = bodyParams
        .map { "\($0.key)=\($0.value)" }
        .joined(separator: "&")
        .data(using: .utf8)
    
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    
    URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("Error requesting token:", error)
            return
        }
        
        guard let data = data else { return }
        
        do {
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let token = json["access_token"] as? String {
                DispatchQueue.main.async {
                    completion(token) // devolve o token para o ViewModel
                }
            }
        } catch {
            print("Error parsing token response:", error)
        }
    }.resume()
}

func fetchUserPlaylists(accessToken: String, completion: @escaping ([Playlist]) -> Void) {
    var allPlaylists: [Playlist] = []

    // ✅ Adiciona Liked Songs no topo
    let likedSongs = Playlist(
        id: "liked_songs",
        name: "Liked Songs",
        description: "Your saved songs",
        ownerName: nil,
        imageURL: URL(string: "https://misc.scdn.co/liked-songs/liked-songs-640.png"),
        totalTracks: 0,
        isPublic: false,
        primaryColor: Color.green,
        tracks: [],
        isLikedSongs: true
    )
    allPlaylists.append(likedSongs)

    var nextURL: URL? = URL(string: "https://api.spotify.com/v1/me/playlists?limit=50")

    func loadPage(url: URL) {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error fetching playlists:", error)
                DispatchQueue.main.async { completion(allPlaylists) }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async { completion(allPlaylists) }
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let items = json["items"] as? [[String: Any]] {

                    for item in items {
                        // Extrai campos obrigatórios
                        guard let id = item["id"] as? String,
                              let name = item["name"] as? String,
                              let tracksInfo = item["tracks"] as? [String: Any],
                              let totalTracks = tracksInfo["total"] as? Int else {
                            continue // pula playlists inválidas
                        }

                        // Campos opcionais
                        let ownerName = (item["owner"] as? [String: Any])?["display_name"] as? String
                        let images = item["images"] as? [[String: Any]]
                        let firstImageURL = (images?.first?["url"] as? String).flatMap { URL(string: $0) }
                        let isPublic = item["public"] as? Bool ?? true
                        let description = item["description"] as? String

                        let primaryColorHex = item["primary_color"] as? String
                        let primaryColor = ColorFromHex(primaryColorHex)

                        let playlist = Playlist(
                            id: id,
                            name: name,
                            description: description,
                            ownerName: ownerName,
                            imageURL: firstImageURL,
                            totalTracks: totalTracks,
                            isPublic: isPublic,
                            primaryColor: primaryColor,
                            tracks: []
                        )

                        allPlaylists.append(playlist)
                    }

                    // Paginação
                    if let nextStr = json["next"] as? String, let next = URL(string: nextStr) {
                        loadPage(url: next) // carrega próxima página
                    } else {
                        DispatchQueue.main.async { completion(allPlaylists) }
                    }

                } else {
                    DispatchQueue.main.async { completion(allPlaylists) }
                }
            } catch {
                print("Error parsing JSON:", error)
                DispatchQueue.main.async { completion(allPlaylists) }
            }

        }.resume()
    }

    if let url = nextURL {
        loadPage(url: url)
    }
}

func ColorFromHex(_ hex: String?) -> Color? {
    guard let hex = hex else { return nil }
    
    var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines)
    if hexString.hasPrefix("#") {
        hexString.removeFirst()
    }
    
    guard let hexValue = UInt64(hexString, radix: 16) else { return nil }

    let r = Double((hexValue >> 16) & 0xFF) / 255.0
    let g = Double((hexValue >> 8) & 0xFF) / 255.0
    let b = Double(hexValue & 0xFF) / 255.0
    
    return Color(red: r, green: g, blue: b)
}

func fetchPlaylistTracks(accessToken: String, playlistID: String, completion: @escaping ([Music]) -> Void) {
    var allTracks: [Music] = []
    var nextURL: URL? = URL(string: "https://api.spotify.com/v1/playlists/\(playlistID)/tracks?limit=50")

    func loadPage(url: URL) {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error fetching playlist tracks:", error)
                completion([])
                return
            }

            guard let data = data else {
                completion([])
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let items = json["items"] as? [[String: Any]] {

                    let musics: [Music] = items.compactMap { item in
                        guard let track = item["track"] as? [String: Any],
                              let id = track["id"] as? String,
                              let name = track["name"] as? String,
                              let artists = track["artists"] as? [[String: Any]],
                              let firstArtist = artists.first,
                              let artistName = firstArtist["name"] as? String
                        else { return nil }

                        let album = track["album"] as? [String: Any]
                        let images = album?["images"] as? [[String: Any]]
                        let firstImageURL = (images?.first?["url"] as? String).flatMap { URL(string: $0) }

                        return Music(id: id, title: name, artist: artistName, imageURL: firstImageURL)
                    }

                    allTracks.append(contentsOf: musics)

                    if let nextStr = json["next"] as? String, let next = URL(string: nextStr) {
                        loadPage(url: next)
                    } else {
                        DispatchQueue.main.async { completion(allTracks) }
                    }
                } else {
                    DispatchQueue.main.async { completion(allTracks) }
                }
            } catch {
                print("Error parsing tracks:", error)
                DispatchQueue.main.async { completion(allTracks) }
            }
        }.resume()
    }

    if let url = nextURL {
        loadPage(url: url)
    }
}

func fetchLikedSongs(accessToken: String, completion: @escaping ([Music]) -> Void) {
    var allTracks: [Music] = []
    var nextURL: URL? = URL(string: "https://api.spotify.com/v1/me/tracks?limit=50")

    func loadPage(url: URL) {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error fetching liked songs:", error)
                completion([])
                return
            }

            guard let data = data else {
                completion([])
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let items = json["items"] as? [[String: Any]] {

                    let musics: [Music] = items.compactMap { item in
                        guard let track = item["track"] as? [String: Any],
                              let id = track["id"] as? String,
                              let name = track["name"] as? String,
                              let artists = track["artists"] as? [[String: Any]],
                              let firstArtist = artists.first,
                              let artistName = firstArtist["name"] as? String
                        else { return nil }

                        let album = track["album"] as? [String: Any]
                        let images = album?["images"] as? [[String: Any]]
                        let firstImageURL = (images?.first?["url"] as? String).flatMap { URL(string: $0) }

                        return Music(id: id, title: name, artist: artistName, imageURL: firstImageURL)
                    }

                    allTracks.append(contentsOf: musics)

                    if let nextStr = json["next"] as? String, let next = URL(string: nextStr) {
                        loadPage(url: next)
                    } else {
                        DispatchQueue.main.async { completion(allTracks) }
                    }
                } else {
                    DispatchQueue.main.async { completion(allTracks) }
                }
            } catch {
                print("Error parsing liked songs:", error)
                DispatchQueue.main.async { completion(allTracks) }
            }
        }.resume()
    }

    if let url = nextURL {
        loadPage(url: url)
    }
}
