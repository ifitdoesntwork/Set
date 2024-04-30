//
//  SetGame.swift
//  Set
//
//  Created by Denis Avdeev on 17.04.2024.
//

import Algorithms
import Foundation

struct SetGame {
    private(set) var cards: [Card]
    private(set) var players: [Player]
    private(set) var claims = [Claim]()
    
    init(
        playersCount: Int
    ) {
        let triStateCases = TriState
            .allCases
        
        cards = product(
            triStateCases,
            product(
                triStateCases,
                product(
                    triStateCases,
                    triStateCases
                )
            )
        )
        .map {
            .init(content: [
                $0.0,
                $0.1.0,
                $0.1.1.0,
                $0.1.1.1
            ])
        }
        .shuffled()
        
        cards
            .deal(count: 12)
        
        players = (0..<playersCount)
            .map { _ in .init() }
    }
    
    private(set) var selection: [Card] {
        get {
            cards.selected
        }
        set {
            if selection.isMatch == true {
                selection
                    .forEach {
                        cards[identifiedAs: $0].location = .pile
                    }
            }
            
            cards
                .forEach {
                    cards[identifiedAs: $0].isSelected = newValue
                        .contains($0)
                }
        }
    }
    
    var activeClaim: Claim? {
        claims
            .first { $0.end > .now }
    }
    
    var isOver: Bool {
        cards.deck.isEmpty
        && selection.count == cards.field.count
        && selection.isMatch == true
    }
    
    mutating func choose(
        _ card: Card
    ) {
        guard
            let claim = activeClaim
        else {
            return
        }
        
        let isMatch = selection.isMatch
        
        selection = selection
            .filter {
                isMatch == nil
                && $0.id != card.id
            }
        + (
            !selection.contains(card)
            || isMatch == false
                ? [card]
                : []
        )
        
        keepScore()
        
        if selection.isMatch != nil {
            endClaim(claim)
        }
    }
    
    private mutating func keepScore() {
        guard
            let isMatch = selection
                .isMatch,
            let player = players
                .first(where: {
                    $0.id == activeClaim?.playerId
                })
        else {
            return
        }
        
        if isMatch {
            let setFindingTime = Date()
                .timeIntervalSince(
                    players[identifiedAs: player].setFindingStart
                )
            
            players[identifiedAs: player].score += max(
                20 - Int(setFindingTime / 5),
                .zero
            )
            
            players[identifiedAs: player].setFindingStart = .now
        } else {
            let hasSet = cards.firstAvailableSet != nil
            
            players[identifiedAs: player].score -= hasSet 
                ? 20 : 10
        }
    }
    
    mutating func deal() {
        cards
            .deal()
    }
    
    mutating func cheat() {
        cards
            .firstAvailableSet
            .map { selection = $0 }
    }
}

// MARK: - Claiming

extension SetGame {
    
    mutating func claim(
        by player: Player
    ) {
        claims
            .append(.init(
                end: .now
                    .addingTimeInterval(Constants.claimTime),
                playerId: player.id
            ))
    }
    
    mutating func endClaim(
        _ claim: Claim
    ) {
        if
            let claimEnd = claims[identifiedAs: claim]?.end,
            (
                selection.isMatch == false
                && claimEnd > .now
            )
            || abs(Date().timeIntervalSince(claimEnd)) < 0.01
        {
            claims[identifiedAs: claim].penaltyEnd = .now
                .addingTimeInterval(Constants.penaltyTime)
        }
        
        claims[identifiedAs: claim]?.end = .now
    }
    
    mutating func endPenalty(
        forClaim claim: Claim
    ) {
        claims[identifiedAs: claim]?.penaltyEnd = .now
    }
    
    struct Constants {
        static let claimTime: TimeInterval = 5
        static let penaltyTime: TimeInterval = 10
    }
}

// MARK: - Models

enum TriState: Int, CaseIterable {
    case first
    case second
    case third
}

extension SetGame {
    
    struct Card: Identifiable {
        
        enum Location {
            case deck
            case field
            case pile
        }
        
        fileprivate(set) var location = Location.deck
        fileprivate(set) var isSelected = false
        
        let content: [TriState]
        let id = UUID()
    }
    
    struct Player: Identifiable {
        var score = 0
        fileprivate var setFindingStart = Date()
        let id = UUID()
    }
    
    struct Claim: Identifiable {
        var end: Date
        var penaltyEnd: Date?
        let playerId: UUID
        let id = UUID()
    }
}

// MARK: - Utilities

private extension Array {
    
    subscript(
        identifiedAs element: Element
    ) -> Element!
    where Element: Identifiable {
        get {
            first { $0.id == element.id }
        }
        set {
            firstIndex { $0.id == element.id }
                .map { index in
                    newValue
                        .map { self[index] = $0 }
                }
        }
    }
}

private extension Array
where Element == SetGame.Card {
    
    func contains(
        _ card: Element
    ) -> Bool {
        
        map(\.id)
            .contains(card.id)
    }
    
    mutating func deal(
        count: Int = 3
    ) {
        deck
            .prefix(count)
            .forEach {
                self[identifiedAs: $0].location = .field
            }
    }
    
    var firstAvailableSet: [Element]? {
        
        field
            .combinations(ofCount: 3)
            .first { $0.isMatch == true }
    }
}

extension Array
where Element == SetGame.Card {
    
    var deck: [Element] {
        
        filter { $0.location == .deck }
    }
    
    var field: [Element] {
        
        filter { $0.location == .field }
    }
    
    var pile: [Element] {
        
        filter { $0.location == .pile }
    }
    
    var selected: [Element] {
        
        filter(\.isSelected)
    }
    
    var isMatch: Bool? {
        
        count == 3
            ? map(\.content)
                .transposed
                .allSatisfy(\.isSet)
            : nil
    }
}

private extension Collection
where Iterator.Element: RandomAccessCollection {
    
    var transposed: [[Element.Element]] {
        
        first?
            .indices
            .map { index in map { $0[index] } }
        ?? []
    }
}

private extension Array
where Element: Hashable {
    
    var isSet: Bool {
        let set = Set(self)
        return set.count == count || set.count == 1
    }
}
