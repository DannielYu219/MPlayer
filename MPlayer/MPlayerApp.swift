//
//  MPlayerApp.swift
//  MPlayer
//
//  Created by DannielYu on 7/13/25.
//

import SwiftUI
import AppKit

@main
struct MPlayerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .ignoresSafeArea(.all)
        }
        .windowStyle(.hiddenTitleBar)
    }
}
