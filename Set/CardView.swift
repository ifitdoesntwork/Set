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
                        card.content.shape.ui
                            .shading(card.content.shading)
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
        CardView(
            card: .init(
                content: .init(
                    color: Theme.Color.red,
                    shape: Theme.Shape.diamond,
                    shading: Theme.Shading.open,
                    number: Theme.Number.one
                )
            )
        )
        CardView(
            card: .init(
                content: .init(
                    color: Theme.Color.green,
                    shape: Theme.Shape.oval,
                    shading: Theme.Shading.solid,
                    number: Theme.Number.three
                )
            )
        )
        CardView(
            card: .init(
                content: .init(
                    color: Theme.Color.purple,
                    shape: Theme.Shape.squiggle,
                    shading: Theme.Shading.striped,
                    number: Theme.Number.two
                )
            )
        )
    }
    .padding()
}
