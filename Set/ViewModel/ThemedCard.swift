//
//  ThemedCard.swift
//  Set
//
//  Created by Denis Avdeev on 06.05.2024.
//

import SwiftUI

struct ThemedCard {
    private let card: SetGame.Card
    private let theme: Theme
    
    let isMatch: Bool?
    let isFaceUp: Bool
    
    init(
        card: SetGame.Card,
        theme: Theme,
        isMatch: Bool?,
        isFaceUp: Bool
    ) {
        self.card = card
        self.theme = theme
        self.isMatch = isMatch
        self.isFaceUp = isFaceUp
    }
}

extension ThemedCard {
    
    var color: Theme.Color {
        theme
            .colors[card.content[0].rawValue]
    }
    
    var shape: Theme.Shape {
        theme
            .shapes[card.content[1].rawValue]
    }
    
    var shading: Theme.Shading {
        theme
            .shadings[card.content[2].rawValue]
    }
    
    var number: Theme.Number {
        theme
            .numbers[card.content[3].rawValue]
    }
    
    var isSelected: Bool {
        card
            .isSelected
    }
    
    var backgroundColor: SwiftUI.Color {
        
        if isSelected {
            switch isMatch {
            case .some(true):
                .green
            case .some(false):
                .red
            case .none:
                .yellow
            }
        } else {
            .white
        }
    }
}
