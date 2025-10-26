//
//  PlaylistInfoView.swift
//  PlaylistPort
//
//  Created by Marlon Ribas on 26/10/25.
//

import SwiftUI

struct PlaylistInfoView: View {
    let playlist: Playlist
    
    var body: some View {
        VStack {
            URLToImageView(
                coverURL: playlist.imageURL,
                width: 200,
                cornerRadius: 16
            )
            .frame(maxWidth: .infinity)
            
            let ownerName = playlist.ownerName ?? ""
            let description = playlist.description ?? ""
            
            VStack(spacing: 8) {
                Text(playlist.name)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                if !description.isEmpty {
                    Text(description)
                        .font(.body)
                        .multilineTextAlignment(.center)
                }
                
                let info = [
                    ownerName,
                    playlist.totalTracks.formatted() + " tracks"
                ]
                
                Text(info.filter { !$0.isEmpty }.joined(separator: " · "))
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
        }
    }
}
