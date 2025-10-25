//
//  PlaylistModel.swift
//  PlaylistPort
//
//  Created by Marlon Ribas on 25/10/25.
//

import Foundation

struct Playlist: Identifiable, Codable {
    let id: String
    let name: String
    let imageURL: URL?
//    var tracks: [Track] = []
}

struct Track: Identifiable, Codable {
    let id: String
    let title: String
    let artist: String
    let imageURL: URL?
}
