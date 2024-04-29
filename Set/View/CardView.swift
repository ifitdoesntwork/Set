//
//  CardView.swift
//  Set
//
//  Created by Denis Avdeev on 17.04.2024.
//

import SwiftUI


struct CardView: View {
    let card: SetGame.Card
    let isMatch: Bool?
    let isFaceUp: Bool
    let theme: Theme
    
    var body: some View {
        
        GeometryReader { geometry in
            
            let aspectRatio = geometry.size.width
            / geometry.size.height
            
            ZStack {
                if isFaceUp {
                    base
                } else {
                    background
                    
                    features(aspectRatio: aspectRatio)
                        .padding(Constants.padding)
                }
            }
            .foregroundStyle(.gray)
        }
    }
}

private extension CardView {
    
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
                    .foregroundStyle(
                        card
                            .backgroundColor(isMatch: isMatch)
                            .opacity(Constants.backgroundOpacity)
                    )
            )
            .overlay(
                base
                    .strokeBorder(
                        lineWidth: Constants.lineWidth
                    )
        )
    }
    
    func features(
        aspectRatio: CGFloat
    ) -> some View {
        
        VStack {
            ForEach(
                1...card.number(from: theme).rawValue,
                id: \.self
            ) { _ in
                
                card
                    .shape(from: theme)
                    .ui(shading: card.shading(from: theme))
                    .padding(Constants.padding)
                    .aspectRatio(
                        aspectRatio * 3,
                        contentMode: .fit
                    )
                    .foregroundStyle(
                        card.color(from: theme).ui
                    )
            }
        }
    }
    
    struct Constants {
        static let cornerRadius: CGFloat = 12
        static let backgroundOpacity: CGFloat = 0.3
        static let lineWidth: CGFloat = 2
        static let padding: CGFloat = 5
    }
}

#Preview {
    
    VStack {
        ForEach(
            TriState.allCases,
            id: \.self
        ) {
            CardView(
                card: .init(
                    content: .init(
                        repeating: $0,
                        count: 4
                    )
                ),
                isMatch: nil,
                isFaceUp: $0.rawValue % 2 == 1,
                theme: .classic
            )
        }
    }
    .padding()
}
