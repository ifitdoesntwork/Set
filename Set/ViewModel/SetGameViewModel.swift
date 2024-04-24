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
    
    typealias Constants = ThemedSetGame.Constants
    
    private static func createGame(
        themed theme: Theme
    ) -> ThemedSetGame {
        .init(
            playersCount: 2,
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
        model.selection
            .isMatch()
    }
    
    var players: [ThemedSetGame.Player] {
        model.players
    }
    
    var canClaim: Bool {
        model.activeClaim == nil
    }
    
    func lastClaim(
        by player: ThemedSetGame.Player
    ) -> ThemedSetGame.Claim? {
        
        model.claims
            .last {
                $0.playerId == player.id
                && (
                    $0.end > .now
                    || $0.penaltyEnd ?? .now > .now
                )
            }
    }
    
    func claim(
        by player: ThemedSetGame.Player
    ) {
        model
            .claim(by: player)
        
        let claim = model.claims.last!
        
        Timer.scheduledTimer(
            withTimeInterval: Constants.claimTime,
            repeats: false
        ) { [weak self] _ in
            
            self?.model
                .endClaim(claim)
            
            self?
                .penalize(claim: claim)
        }
    }
    
    func choose(
        _ card: ThemedSetGame.Card
    ) {
        model
            .choose(card)
        
        if model.selection.isMatch() == false {
            penalize(
                claim: model.claims.last!
            )
        }
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
    
    func cheat() {
        model
            .cheat()
    }
    
    private func penalize(
        claim: ThemedSetGame.Claim
    ) {
        Timer.scheduledTimer(
            withTimeInterval: Constants.penaltyTime,
            repeats: false
        ) { [weak self] _ in
            
            self?.model
                .endPenalty(forClaim: claim)
        }
    }
}
