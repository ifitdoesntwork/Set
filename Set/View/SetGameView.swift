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
        
        panel(for: viewModel.players[0])
            .rotationEffect(.radians(.pi))
        
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
        .padding(.horizontal)
        
        panel(for: viewModel.players[1])
    }
    
    private func panel(
        for player: SetGameViewModel.ThemedSetGame.Player
    ) -> some View {
        
        HStack {
            
            commonControls(for: player)
            
            Spacer()
            
            let claim = viewModel.lastClaim(by: player)
            
            if let claim {
                Text(
                    (claim.penaltyEnd ?? claim.end) + 0.5,
                    style: .timer
                )
                .foregroundStyle(
                    claim.penaltyEnd == nil ? .green : .red
                )
                .font(.title)
                .monospacedDigit()
            }
            
            Button {
                viewModel
                    .claim(by: player)
            } label: {
                Image(
                    systemName: "exclamationmark.circle.fill"
                )
                .font(.largeTitle)
            }
            .disabled(
                !viewModel.canClaim
                || claim?.penaltyEnd != nil
            )
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private func commonControls(
        for player: SetGameViewModel.ThemedSetGame.Player
    ) -> some View {
        
        Button {
            viewModel.deal()
        } label: {
            Image(
                systemName: "rectangle.stack.fill.badge.plus"
            )
            .font(.largeTitle)
        }
        .disabled(viewModel.deckIsEmpty)
        
        Button {
            viewModel.reset()
        } label: {
            Image(
                systemName: "arrow.counterclockwise.circle.fill"
            )
            .font(.largeTitle)
        }
        
        let isMatch = viewModel.isMatch == true
        
        Button {
            viewModel.cheat()
        } label: {
            Text("Score: \(player.score)")
                .font(.title)
        }
        .foregroundStyle(isMatch ? .black : .blue)
        .disabled(isMatch)
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
