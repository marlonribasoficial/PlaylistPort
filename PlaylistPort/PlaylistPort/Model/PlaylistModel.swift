//
//  PlaylistModel.swift
//  PlaylistPort
//
//  Created by Marlon Ribas on 25/10/25.
//

import Foundation

struct Playlist: Identifiable {
    let id: String
    let name: String
    let imageURL: URL?
    var isLikedSongs: Bool = false
    var tracks: [Music] = []
}


struct Music: Identifiable {
    let id: String
    let title: String
    let artist: String
    let imageURL: URL?
}
