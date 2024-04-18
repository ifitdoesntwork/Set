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
            .indices[0..<12]
            .forEach { cards[$0].state = .dealt }
    }
    
    private var chosenCards: [Card] {
        cards
            .filter(\.isChosen)
    }
    
    var isMatch: Bool? {
        guard 
            chosenCards.count == 3
        else {
            return nil
        }
        
        return chosenCards
            .map(\.content)
            .hashables()
            .allSatisfy(\.isSet)
    }
    
    mutating func choose(_ card: Card) {
        cards
            .firstIndex { $0.id == card.id }
            .map { cards[$0].isChosen = true }
    }
    
    struct Card: Identifiable {
        
        struct Content {
            let color: Color
            let shape: Shape
            let shading: Shading
            let number: Number
        }
        
        enum State {
            case inDeck
            case dealt
            case discarded
        }
        
        fileprivate(set) var state = State.inDeck
        fileprivate(set) var isChosen = false
        
        let content: Content
        let id = UUID().uuidString
    }
}

private extension Array {
    
    func hashables<T, U, V, W>() -> [[AnyHashable]]
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
