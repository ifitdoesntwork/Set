//
//  Cardify.swift
//  Memorize
//
//  Created by CS193p Instructor on 4/26/23.
//

import SwiftUI

struct Cardify<S: ShapeStyle>: ViewModifier, Animatable {
    private var rotation: Double
    private let backgroundStyle: S
    
    var animatableData: Double {
        get {
            rotation
        }
        set {
            rotation = newValue
        }
    }
    
    init(
        isFaceUp: Bool,
        backgroundStyle: S
    ) {
        self.rotation = isFaceUp ? .zero : .pi
        self.backgroundStyle = backgroundStyle
    }
    
    func body(
        content: Content
    ) -> some View {
        
        ZStack {
            if isFaceUp {
                background
                content
            } else {
                base
            }
        }
        .rotation3DEffect(
            .radians(rotation),
            axis: (x: 0, y: 1, z: 0)
        )
    }
}

private extension Cardify {
    
    private var isFaceUp: Bool {
        rotation < .pi / 2
    }
    
    var base: some InsettableShape {
        
        RoundedRectangle(
            cornerRadius: Constants.cornerRadius
        )
    }
    
    var background: some View {
        
        base
            .foregroundStyle(.background)
            .overlay(
                base
                    .foregroundStyle(backgroundStyle)
            )
            .overlay(
                base
                    .strokeBorder(
                        lineWidth: Constants.lineWidth
                    )
        )
    }
    
    struct Constants {
        static var cornerRadius: CGFloat { 12 }
        static var lineWidth: CGFloat { 2 }
    }
}

extension View {
    
    func cardify(
        isFaceUp: Bool,
        backgroundStyle: some ShapeStyle
    ) -> some View {
        
        modifier(Cardify(
            isFaceUp: isFaceUp,
            backgroundStyle: backgroundStyle
        ))
    }
}
