//
//  Theme.swift
//  Set
//
//  Created by Denis Avdeev on 17.04.2024.
//

struct Theme {
    
    enum Color: CaseIterable {
        case red
        case green
        case purple
    }
    
    enum Shape: CaseIterable {
        case diamond
        case squiggle
        case oval
    }
    
    enum Shading: CaseIterable {
        case solid
        case striped
        case open
    }
    
    enum Number: Int, CaseIterable {
        case one = 1
        case two
        case three
    }
    
    let colors: Set<Color>
    let shapes: Set<Shape>
    let shadings: Set<Shading>
    let numbers: Set<Number>
    
    static let classic = Self(
        colors: .init(Color.allCases),
        shapes: .init(Shape.allCases),
        shadings: .init(Shading.allCases),
        numbers: .init(Number.allCases)
    )
}

extension Set {
    
    subscript(
        index: Int
    ) -> Element {
        
        Array(self)[index]
    }
}
