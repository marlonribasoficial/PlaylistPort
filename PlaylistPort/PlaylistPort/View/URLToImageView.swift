//
//  URLToImageView.swift
//  PlaylistPort
//
//  Created by Marlon Ribas on 26/10/25.
//

import SwiftUI

struct URLToImageView: View {
    var coverURL: URL?
    let width: CGFloat
    let cornerRadius: CGFloat
    
    init(coverURL: URL? = nil,
         width: CGFloat,
         cornerRadius: CGFloat) {
        self.coverURL = coverURL
        self.width = width
        self.cornerRadius = cornerRadius
    }
    
    var body: some View {
        if let url = coverURL {
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(width: width, height: width)
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: width, height: width)
                        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                        .overlay(
                                RoundedRectangle(cornerRadius: cornerRadius)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 0.5)
                            )
                case .failure:
                    placeholder
                @unknown default:
                    placeholder
                }
            }
        } else {
            placeholder
        }
    }
    
    private var placeholder: some View {
        Image(systemName: "music.note")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: width, height: width)
            .foregroundColor(.gray)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}
