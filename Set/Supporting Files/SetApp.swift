//
//  SetApp.swift
//  Set
//
//  Created by Denis Avdeev on 17.04.2024.
//

import SwiftUI

@main
struct SetApp: App {
    @StateObject var game = ThemedGame()
    
    var body: some Scene {
        WindowGroup {
            SetGameView(themedGame: game)
        }
    }
}
