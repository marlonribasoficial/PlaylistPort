//
//  imageSongURL.swift
//  PlaylistPort
//
//  Created by Marlon Ribas on 25/10/25.
//

import SwiftUI

struct PlaylistCoverView: View {
    var coverURL: URL?
    let width: CGFloat
    let cornerRadius: CGFloat
    @Binding var preloadedImage: UIImage?
    
    init(coverURL: URL? = nil,
         width: CGFloat,
         cornerRadius: CGFloat,
         preloadedImage: Binding<UIImage?>? = nil)
    {
        self.coverURL = coverURL
        self.width = width
        self.cornerRadius = cornerRadius
        
        if let preloadedImage = preloadedImage {
            self._preloadedImage = preloadedImage
        } else {
            self._preloadedImage = .constant(nil)
        }
    }
    
    var body: some View {
        if let image = preloadedImage {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: width, height: width)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        } else if let url = coverURL {
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
