//
//  SetGameViewModel.swift
//  Set
//
//  Created by Denis Avdeev on 17.04.2024.
//

import SwiftUI

class SetGameViewModel: ObservableObject {
    
    private static func createGame() -> SetGame {
        .init(
            playersCount: 2
        )
    }
    
    private(set) var theme = Theme.classic
    @Published private var model = SetGameViewModel.createGame()
    
    var cards: [SetGame.Card] {
        model.cards
            .filter { $0.location == .dealt }
    }
    
    var deckIsEmpty: Bool {
        model.cards
            .deck
            .isEmpty
    }
    
    var isMatch: Bool? {
        model.selection
            .isMatch
    }
    
    var players: [SetGame.Player] {
        model.players
    }
    
    var canClaim: Bool {
        model.activeClaim == nil
    }
    
    func lastClaim(
        by player: SetGame.Player
    ) -> SetGame.Claim? {
        
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
        by player: SetGame.Player
    ) {
        model
            .claim(by: player)
        
        let claim = model.claims.last!
        
        Timer.scheduledTimer(
            withTimeInterval: SetGame.Constants.claimTime,
            repeats: false
        ) { [weak self] _ in
            
            self?.model
                .endClaim(claim)
            
            self?
                .penalize(claim: claim)
        }
    }
    
    func choose(
        _ card: SetGame.Card
    ) {
        model
            .choose(card)
        
        if model.selection.isMatch == false {
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
        model = Self.createGame()
    }
    
    func cheat() {
        model
            .cheat()
    }
    
    private func penalize(
        claim: SetGame.Claim
    ) {
        Timer.scheduledTimer(
            withTimeInterval: SetGame.Constants.penaltyTime,
            repeats: false
        ) { [weak self] _ in
            
            self?.model
                .endPenalty(forClaim: claim)
        }
    }
}
