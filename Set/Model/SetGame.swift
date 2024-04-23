//
//  SetGame.swift
//  Set
//
//  Created by Denis Avdeev on 17.04.2024.
//

import Algorithms
import Foundation

struct SetGame<Color, Shape, Shading, Number>
where Color: Hashable,
      Shape: Hashable,
      Shading: Hashable,
      Number: Hashable
{
    private(set) var cards: [Card]
    private(set) var score = 0
    private var setFindingStart = Date()
    
    init(
        colorCount: Int,
        shapeCount: Int,
        shadingCount: Int,
        numberCount: Int,
        cardContentFactory: (Int, Int, Int, Int) -> Card.Content
    ) {
        cards = (0..<colorCount).flatMap { colorIndex in
            (0..<shapeCount).flatMap { shapeIndex in
                (0..<shadingCount).flatMap { shadingIndex in
                    (0..<numberCount).map { numberIndex in
                        .init(content: cardContentFactory(
                            colorIndex,
                            shapeIndex,
                            shadingIndex,
                            numberIndex
                        ))
                    }
                }
            }
        }
        .shuffled()
        
        cards
            .deal(count: 12)
    }
    
    private(set) var selection: [Card] {
        get {
            cards
                .selected()
        }
        set {
            if selection.isMatch() == true {
                cards
                    .deal()
            }
            
            cards
                .forEach {
                    cards[identifiedAs: $0].isSelected = newValue
                        .contains($0)
                }
        }
    }
    
    mutating func choose(
        _ card: Card
    ) {
        let isMatch = selection
            .isMatch()
        
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
    }
    
    private mutating func keepScore() {
        guard
            let isMatch = selection
                .isMatch()
        else {
            return
        }
        
        if isMatch {
            let setFindingTime = Date()
                .timeIntervalSince(setFindingStart)
            
            score += max(
                200 - Int(setFindingTime),
                .zero
            )
            
            setFindingStart = Date()
        } else {
            let hasSet = cards
                .firstAvailableSet()
            != nil
            
            score -= hasSet ? 200 : 100
        }
    }
    
    mutating func deal() {
        cards
            .deal()
    }
    
    mutating func cheat() {
        cards
            .firstAvailableSet()
            .map { selection = $0 }
    }
}

extension SetGame {
    
    struct Card: Identifiable {
        
        struct Content {
            let color: Color
            let shape: Shape
            let shading: Shading
            let number: Number
        }
        
        enum Location {
            case deck
            case dealt
            case matched
        }
        
        fileprivate(set) var location = Location.deck
        fileprivate(set) var isSelected = false
        
        let content: Content
        let id = UUID()
    }
}

private extension Array {
    
    subscript<T, U, V, W>(
        identifiedAs card: Element
    ) -> Element!
    where Element == SetGame<T, U, V, W>.Card {
        get {
            first { $0.id == card.id }
        }
        set {
            firstIndex { $0.id == card.id }
                .map { index in
                    newValue
                        .map { self[index] = $0 }
                }
        }
    }
    
    func contains<T, U, V, W>(
        _ card: Element
    ) -> Bool
    where Element == SetGame<T, U, V, W>.Card {
        
        map(\.id)
            .contains(card.id)
    }
    
    mutating func deal<T, U, V, W>(
        count: Int = 3
    ) where Element == SetGame<T, U, V, W>.Card {
        
        let cards = deck()
            .prefix(count)
        
        cards
            .forEach {
                self[identifiedAs: $0].location = .dealt
            }
        
        if selected().isMatch() == true {
            let selected = selected()
            
            selected
                .compactMap { card in
                    firstIndex { $0.id == card.id }
                }
                .forEach { selectedIndex in
                    self[selectedIndex].location = .matched
                    self[selectedIndex].isSelected = false
                    
                    if cards.count == selected.count {
                        
                        lastIndex { $0.location == .dealt }
                            .map { lastDealtIndex in
                                swapAt(
                                    selectedIndex,
                                    lastDealtIndex
                                )
                            }
                    }
                }
        }
    }
    
    func features<T, U, V, W>() -> [[AnyHashable]]
    where Element == SetGame<T, U, V, W>.Card.Content {
        [
            map(\.color),
            map(\.number),
            map(\.shading),
            map(\.shape)
        ]
    }
    
    func firstAvailableSet<T, U, V, W>() -> [Element]?
    where Element == SetGame<T, U, V, W>.Card {
        
        filter { $0.location == .dealt }
            .combinations(ofCount: 3)
            .first { $0.isMatch() == true }
    }
}

extension Array {
    
    func deck<T, U, V, W>() -> [Element]
    where Element == SetGame<T, U, V, W>.Card {
        
        filter { $0.location == .deck }
    }
    
    func selected<T, U, V, W>() -> [Element]
    where Element == SetGame<T, U, V, W>.Card {
        
        filter(\.isSelected)
    }
    
    func isMatch<T, U, V, W>() -> Bool?
    where Element == SetGame<T, U, V, W>.Card {
        
        count == 3
            ? map(\.content)
                .features()
                .allSatisfy(\.isSet)
            : nil
    }
}

private extension Array where Element: Hashable {
    
    var isSet: Bool {
        let set = Set(self)
        return set.count == count || set.count == 1
    }
}
