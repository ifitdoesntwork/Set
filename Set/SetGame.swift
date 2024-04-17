//
//  SetGame.swift
//  Set
//
//  Created by Denis Avdeev on 17.04.2024.
//

struct SetGame<Color, Shape, Shading, Number> {
    private(set) var card: Card
    
    init(
        cardContentFactory: () -> Card.Content
    ) {
        card = .init(content: cardContentFactory())
    }
    
    struct Card {
        
        struct Content {
            let color: Color
            let shape: Shape
            let shading: Shading
            let number: Number
        }
        
        let content: Content
    }
}
