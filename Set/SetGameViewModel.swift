//
//  SetGameViewModel.swift
//  Set
//
//  Created by Denis Avdeev on 17.04.2024.
//

import SwiftUI

class SetGameViewModel: ObservableObject {
    
    typealias ThemedSetGame = SetGame<
        Theme.Color,
        Theme.Shape,
        Theme.Shading,
        Theme.Number
    >
    
    private static func createGame(
        themed theme: Theme
    ) -> ThemedSetGame {
        .init {
            .init(
                color: theme.colors.randomElement()!,
                shape: theme.shapes.randomElement()!,
                shading: theme.shadings.randomElement()!,
                number: theme.numbers.randomElement()!
            )
        }
    }
    
    private var theme: Theme
    @Published private var model: ThemedSetGame
    
    init() {
        theme = .classic
        model = Self.createGame(themed: theme)
    }
    
    var card: ThemedSetGame.Card {
        model.card
    }
}
