//
//  SetGameView.swift
//  Set
//
//  Created by Denis Avdeev on 17.04.2024.
//

import SwiftUI

struct SetGameView: View {
    @ObservedObject var viewModel: SetGameViewModel
    
    var body: some View {
        buttons
        
        AspectVGrid(
            viewModel.cards,
            aspectRatio: Constants.aspectRatio,
            minWidth: Constants.minWidth
        ) { card in
            
            CardView(card: card, isMatch: viewModel.isMatch)
                .padding(Constants.cardPadding)
                .onTapGesture {
                    viewModel
                        .choose(card)
                }
        }
        .padding()
    }
    
    private var buttons: some View {
        HStack {
            Button {
                viewModel.reset()
            } label: {
                Image(
                    systemName: "arrow.counterclockwise.circle.fill"
                )
                .font(.largeTitle)
            }
            
            Spacer()
            
            Button {
                viewModel.deal()
            } label: {
                Image(
                    systemName: "rectangle.stack.fill.badge.plus"
                )
                .font(.largeTitle)
            }
            .disabled(viewModel.deckIsEmpty)
        }
        .padding(.horizontal)
    }
    
    private struct Constants {
        static let aspectRatio: CGFloat = 2/3
        static let minWidth: CGFloat = 72
        static let cardPadding: CGFloat = 4
    }
}

#Preview {
    SetGameView(viewModel: .init())
}
