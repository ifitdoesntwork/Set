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
    
    @Published private var model = SetGameViewModel.createGame(
        themed: .classic
    )
    
    var cards: [ThemedSetGame.Card] {
        model.cards
            .filter { $0.location == .dealt }
    }
    
    var deckIsEmpty: Bool {
        model.cards
            .deck()
            .isEmpty
    }
    
    var isMatch: Bool? {
        model.cards
            .isMatch()
    }
    
    var score: Int {
        model.score
    }
    
    func choose(
        _ card: ThemedSetGame.Card
    ) {
        model
            .choose(card)
    }
    
    func deal() {
        model
            .deal()
    }
    
    func reset() {
        model = Self.createGame(
            themed: .classic
        )
    }
}
