//
//  PlaylistModel.swift
//  PlaylistPort
//
//  Created by Marlon Ribas on 25/10/25.
//

import Foundation
import SwiftUI

struct Playlist: Identifiable {
    let id: String
    let name: String
    let description: String?
    let ownerName: String?
    let imageURL: URL?
    var totalTracks: Int
    let isPublic: Bool
    let primaryColor: Color?
    var tracks: [Music]
    var isLikedSongs: Bool = false
}

struct Music: Identifiable {
    let id: String
    let title: String
    let artist: String
    let imageURL: URL?
}
