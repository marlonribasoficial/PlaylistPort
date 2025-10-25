//
//  SpotifyAuth.swift
//  PlaylistPort
//
//  Created by Marlon Ribas on 25/10/25.
//

import CommonCrypto
import Foundation
import UIKit

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
    let url = URL(string: "https://api.spotify.com/v1/me/playlists")!
    
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
    
    URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("Error fetching playlists:", error)
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
                
                let playlists: [Playlist] = items.compactMap { item in
                    guard let id = item["id"] as? String,
                          let name = item["name"] as? String else {
                        return nil
                    }
                    
                    // pega imagem se existir
                    let images = item["images"] as? [[String: Any]]
                    let imageURLString = images?.first?["url"] as? String
                    let imageURL = imageURLString != nil ? URL(string: imageURLString!) : nil
                    
                    return Playlist(id: id, name: name, imageURL: imageURL)
                }
                
                completion(playlists)
            } else {
                completion([])
            }
        } catch {
            print("Error parsing playlists response:", error)
            completion([])
        }
    }.resume()
}
