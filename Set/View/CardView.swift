//
//  CardView.swift
//  Set
//
//  Created by Denis Avdeev on 17.04.2024.
//

import SwiftUI

struct CardView: View {
    let card: ThemedCard
    
    var body: some View {
        
        GeometryReader { geometry in
            
            let aspectRatio = geometry.size.width
            / geometry.size.height
            
            features(aspectRatio: aspectRatio)
                .padding(Constants.padding)
                .cardify(
                    isFaceUp: card.isFaceUp,
                    backgroundStyle: card.backgroundColor
                        .opacity(Constants.backgroundOpacity)
                )
                .foregroundStyle(.gray)
        }
    }
}

private extension CardView {
    
    func features(
        aspectRatio: CGFloat
    ) -> some View {
        
        VStack {
            ForEach(
                1...card.number.rawValue,
                id: \.self
            ) { _ in
                
                card.shape
                    .ui(shading: card.shading)
                    .padding(Constants.padding)
                    .aspectRatio(
                        aspectRatio * 3,
                        contentMode: .fit
                    )
                    .foregroundStyle(card.color.ui)
                    .match(
                        isMatch: card.isMatch == true,
                        isSelected: card.isSelected
                    )
                    .mismatch(
                        isMismatch: card.isMatch == false,
                        isSelected: card.isSelected
                    )
            }
        }
    }
    
    struct Constants {
        static let backgroundOpacity: CGFloat = 0.3
        static let padding: CGFloat = 5
    }
}

private extension View {
    
    func match(
        isMatch: Bool,
        isSelected: Bool
    ) -> some View {
        
        rotationEffect(.radians(
            isSelected && isMatch
                ? .pi * 2 : .zero
        ))
        .animation(
            isSelected
                ? .linear(duration: 0.5)
                  .repeatCount(2, autoreverses: false)
                : nil,
            value: isSelected && isMatch
        )
    }
    
    func mismatch(
        isMismatch: Bool,
        isSelected: Bool
    ) -> some View {
        
        rotation3DEffect(
            .radians(
                isSelected && isMismatch
                    ? .pi * 2 : .zero
            ),
            axis: (x: 0, y: 1, z: 0)
        )
        .animation(
            isSelected 
                ? .linear(duration: 0.4) : nil,
            value: isSelected && isMismatch
        )
    }
}

#Preview {
    
    VStack {
        ForEach(
            TriState.allCases,
            id: \.self
        ) {
            CardView(card: .init(
                card: .init(
                    content: .init(
                        repeating: $0,
                        count: 4
                    )
                ),
                theme: .classic,
                isMatch: nil,
                isFaceUp: $0.rawValue % 2 == 0
            ))
        }
    }
    .padding()
}
