//
//  PlaylistPortApp.swift
//  PlaylistPort
//
//  Created by Marlon Ribas on 25/10/25.
//

import SwiftUI

@main
struct PlaylistPortApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    handleRedirectURL(url) // trata o retorno do Spotify
                }
        }
    }
}
