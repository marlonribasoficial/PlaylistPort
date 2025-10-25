//
//  PlaylistPortApp.swift
//  PlaylistPort
//
//  Created by Marlon Ribas on 25/10/25.
//

import SwiftUI

@main
struct PlaylistPortApp: App {
    @StateObject private var viewModel = SpotifyViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel)
                .onOpenURL { url in
                    viewModel.handleCallbackWithToken(url: url)
                }
        }
    }
}
