//
//  ThemedGame.swift
//  Set
//
//  Created by Denis Avdeev on 17.04.2024.
//

import SwiftUI

class ThemedGame: ObservableObject {
    private(set) var theme = Theme.classic
    @Published private var game = ThemedGame.createGame()
    
    var cards: [SetGame.Card] {
        game.cards
    }
    
    var isOver: Bool {
        game.isOver
    }
    
    var isMatch: Bool? {
        game.selection.isMatch
    }
    
    var players: [SetGame.Player] {
        game.players
    }
    
    var canClaim: Bool {
        game.activeClaim == nil
        && !isOver
    }
    
    func card(
        presenting card: SetGame.Card,
        isFaceUp: Bool
    ) -> ThemedCard {
        
        .init(
            card: card,
            theme: theme,
            isMatch: isMatch,
            isFaceUp: isFaceUp
        )
    }
    
    func timerEnd(
        for player: SetGame.Player
    ) -> Date? {
        
        lastClaim(by: player)
            .map { $0.penaltyEnd ?? $0.end }
    }
    
    func hasPenalty(
        for player: SetGame.Player
    ) -> Bool {
        
        lastClaim(by: player)?.penaltyEnd != nil
    }
    
    func claim(
        by player: SetGame.Player
    ) {
        game
            .claim(by: player)
        
        let claim = game.claims.last!
        
        Timer.scheduledTimer(
            withTimeInterval: SetGame.Constants.claimTime,
            repeats: false
        ) { [weak self] _ in
            
            self?.game
                .endClaim(claim)
            
            self?
                .penalize(claim: claim)
        }
    }
    
    func choose(
        _ card: SetGame.Card
    ) {
        game
            .choose(card)
        
        if game.selection.isMatch == false {
            penalize(
                claim: game.claims.last!
            )
        }
    }
    
    func deal() {
        game
            .deal()
    }
    
    func reset() {
        game = Self.createGame()
    }
    
    func cheat() {
        game
            .cheat()
    }
}

private extension ThemedGame {
    
    static func createGame() -> SetGame {
        .init(
            playersCount: 2
        )
    }
    
    func lastClaim(
        by player: SetGame.Player
    ) -> SetGame.Claim? {
        
        game.claims
            .last {
                $0.playerId == player.id
                && (
                    $0.end > .now
                    || $0.penaltyEnd ?? .now > .now
                )
            }
    }
    
    func penalize(
        claim: SetGame.Claim
    ) {
        Timer.scheduledTimer(
            withTimeInterval: SetGame.Constants.penaltyTime,
            repeats: false
        ) { [weak self] _ in
            
            self?.game
                .endPenalty(forClaim: claim)
        }
    }
}
