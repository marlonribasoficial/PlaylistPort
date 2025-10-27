//
//  PlaylistPortApp.swift
//  PlaylistPort
//
//  Created by Marlon Ribas on 25/10/25.
//

import SwiftUI

@main
struct PlaylistPortApp: App {
    @StateObject var viewModel = SpotifyViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
                .onOpenURL { url in
                    viewModel.handleSpotifyCallback(url: url)
                }
        }
    }
}
