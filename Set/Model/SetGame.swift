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
    
    private var selectedCards: [Card] {
        cards
            .filter(\.isSelected)
    }
    
    private var dealCount: Int {
        cards
            .filter(\.isDealt)
            .count
    }
    
    var isMatch: Bool? {
        selectedCards.count == 3
        ? selectedCards
            .map(\.content)
            .features()
            .allSatisfy(\.isSet)
        : nil
    }
    
    mutating func choose(
        _ card: Card
    ) {
        switch isMatch {
        case .some(true):
            processMatch(chosenCard: card)
        case .some(false):
            break
        case .none:
            cards[id: card.id]
                .isSelected
                .toggle()
        }
    }
    
    private mutating func processMatch(
        chosenCard: Card
    ) {
        let selectionIndices = selectedCards
            .map { card in
                cards
                    .firstIndex { $0.id == card.id }
            }
            .compactMap { $0 }
        
        let selectionIds = selectedCards
            .map(\.id)
        
        let oldDealCount = dealCount
        
        selectedCards
            .map(\.id)
            .forEach {
                cards[id: $0].location = .matched
                cards[id: $0].isSelected = false
            }
        
        cards
            .deal()
        
        if dealCount == oldDealCount {
            selectionIndices
                .forEach {
                    cards.swapAt(
                        $0,
                        cards
                            .lastIndex(where: \.isDealt)!
                    )
                }
        }
        
        if !selectionIds.contains(chosenCard.id) {
            choose(chosenCard)
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
        
        var isDealt: Bool {
            location == .dealt
        }
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
    
    mutating func deal<T, U, V, W>(
        count: Int = 3
    ) where Element == SetGame<T, U, V, W>.Card {
        
        filter { $0.location == .deck }
            .prefix(count)
            .map(\.id)
            .forEach { self[id: $0].location = .dealt }
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
