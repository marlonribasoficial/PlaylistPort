//
//  SpotifyAuth.swift
//  PlaylistPort
//
//  Created by Marlon Ribas on 25/10/25.
//

import CommonCrypto
import Foundation
import UIKit

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
    let codeChallenge = generateCodeChallenge(codeVerifier: codeVerifier)
    
    let authURLString = "https://accounts.spotify.com/authorize?response_type=code&client_id=\(clientID)&scope=\(scopes)&redirect_uri=\(redirectURI)&code_challenge_method=S256&code_challenge=\(codeChallenge)"
    
    guard let url = URL(string: authURLString) else { return }

    UIApplication.shared.open(url) // ✅ isso abre o Safari
}
