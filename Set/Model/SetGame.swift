//
//  SetGame.swift
//  Set
//
//  Created by Denis Avdeev on 17.04.2024.
//

import Foundation

struct SetGame<Color, Shape, Shading, Number>
where Color: Hashable,
      Shape: Hashable,
      Shading: Hashable,
      Number: Hashable
{
    private(set) var cards: [Card]
    
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
    
    var isMatch: Bool? {
        cards.selected().count == 3
        ? cards
            .selected()
            .map(\.content)
            .features()
            .allSatisfy(\.isSet)
        : nil
    }
    
    mutating func choose(
        _ card: Card
    ) {
        let selectionIds = cards
            .selected()
            .map(\.id)
        
        let isMatch = isMatch
        
        switch isMatch {
        case .some(true):
            selectionIds
                .forEach {
                    cards[id: $0].location = .matched
                }
            
            cards
                .deal()
            
            fallthrough
        case .some(false):
            selectionIds
                .forEach {
                    cards[id: $0].isSelected = false
                }
            
            fallthrough
        case .none:
            if !(
                selectionIds.contains(card.id)
                && isMatch == .some(true)
            ) {
                cards[id: card.id]
                    .isSelected
                    .toggle()
            }
        }
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
        let id = UUID().uuidString
    }
}

private extension Array {
    
    subscript<T, U, V, W>(
        id id: String
    ) -> SetGame<T, U, V, W>.Card!
    where Element == SetGame<T, U, V, W>.Card {
        get {
            first { $0.id == id }
        }
        set {
            firstIndex { $0.id == id }
                .map { index in
                    newValue
                        .map { self[index] = $0 }
                }
        }
    }
    
    func selected<T, U, V, W>() -> [SetGame<T, U, V, W>.Card]
    where Element == SetGame<T, U, V, W>.Card {
        
        filter(\.isSelected)
    }
    
    mutating func deal<T, U, V, W>(
        count: Int = 3
    ) where Element == SetGame<T, U, V, W>.Card {
        
        let cards = filter { $0.location == .deck }
            .prefix(count)
        
        cards
            .map(\.id)
            .forEach { self[id: $0].location = .dealt }
        
        if cards.count == selected().count {
            
            selected()
                .compactMap { card in
                    firstIndex { $0.id == card.id }
                }
                .forEach { selectedIndex in
                    
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
    
    func features<T, U, V, W>() -> [[AnyHashable]]
    where Element == SetGame<T, U, V, W>.Card.Content {
        [
            map(\.color),
            map(\.number),
            map(\.shading),
            map(\.shape)
        ]
    }
}

private extension Array where Element: Hashable {
    
    var isSet: Bool {
        let set = Set(self)
        return set.count == count || set.count == 1
    }
}
