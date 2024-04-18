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
        .init(
            colorCount: theme.colors.count,
            shapeCount: theme.shapes.count,
            shadingCount: theme.shadings.count,
            numberCount: theme.numbers.count
        ) {
            .init(
                color: theme.colors[$0],
                shape: theme.shapes[$1],
                shading: theme.shadings[$2],
                number: theme.numbers[$3]
            )
        }
    }
    
    private var theme: Theme
    @Published private var model: ThemedSetGame
    
    init() {
        theme = .classic
        model = Self.createGame(themed: theme)
    }
    
    var cards: [ThemedSetGame.Card] {
        model.cards
            .filter { $0.state == .dealt }
    }
    
    var isMatch: Bool? {
        model.isMatch
    }
    
    func choose(_ card: ThemedSetGame.Card) {
        model
            .choose(card)
    }
}
