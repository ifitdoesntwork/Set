//
//  CardView.swift
//  Set
//
//  Created by Denis Avdeev on 17.04.2024.
//

import SwiftUI


struct CardView: View {
    let card: SetGameViewModel.ThemedSetGame.Card
    
    var body: some View {
        GeometryReader { geometry in
            let aspectRatio = geometry.size.width
            / geometry.size.height
            
            ZStack {
                RoundedRectangle(
                    cornerRadius: Constants.cornerRadius
                )
                .strokeBorder(
                    lineWidth: Constants.lineWidth
                )
                
                VStack {
                    ForEach(
                        1...card.content.number.rawValue,
                        id: \.self
                    ) { _ in
                        card.content.shape
                            .ui(shading: card.content.shading)
                            .padding(Constants.padding)
                            .aspectRatio(
                                aspectRatio * 3,
                                contentMode: .fit
                            )
                            .foregroundStyle(
                                card.content.color.ui
                            )
                    }
                }
                .padding(Constants.padding)
            }
        }
    }
    
    private struct Constants {
        static let cornerRadius: CGFloat = 12
        static let lineWidth: CGFloat = 2
        static let padding: CGFloat = 5
    }
}

#Preview {
    VStack {
        
        let count = min(
            Theme.classic.colors.count,
            Theme.classic.numbers.count,
            Theme.classic.shadings.count,
            Theme.classic.shapes.count
        )
        
        ForEach(0..<count, id: \.self) {
            CardView(card: .init(
                content: .init(
                    color: Array(Theme.classic.colors)[$0],
                    shape: Array(Theme.classic.shapes)[$0],
                    shading: Array(Theme.classic.shadings)[$0],
                    number: Array(Theme.classic.numbers)[$0]
                )
            ))
        }
    }
    .padding()
}
