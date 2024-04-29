//
//  SetGameView.swift
//  Set
//
//  Created by Denis Avdeev on 17.04.2024.
//

import SwiftUI

struct SetGameView: View {
    @ObservedObject var themedGame: ThemedGame
    
    var body: some View {
        
        panel(for: themedGame.players[0])
            .rotationEffect(.radians(.pi))
        
        cards
            .padding(.horizontal)
        
        panel(for: themedGame.players[1])
    }
}

private extension SetGameView {
    
    var cards: some View {
        
        AspectVGrid(
            themedGame.cards,
            aspectRatio: Constants.aspectRatio,
            minWidth: Constants.minWidth
        ) { card in
            
            CardView(
                card: card,
                isMatch: themedGame.isMatch,
                theme: themedGame.theme
            )
            .padding(Constants.cardPadding)
            .onTapGesture {
                themedGame
                    .choose(card)
            }
        }
    }
    
    // MARK: - Panel
    
    func panel(
        for player: SetGame.Player
    ) -> some View {
        
        HStack {
            commonControls(for: player)
            
            Spacer()
            
            if 
                let timerEnd = themedGame
                    .timerEnd(for: player)
            {
                timer(
                    for: player,
                    timerEnd: timerEnd
                )
            }
            
            claim(for: player)
        }
        .padding(.horizontal)
    }
    
    func timer(
        for player: SetGame.Player,
        timerEnd: Date
    ) -> some View {
        
        Text(timerEnd + 0.5, style: .timer)
            .foregroundStyle(
                themedGame.hasPenalty(for: player)
                    ? .red : .green
            )
            .font(.title)
            .monospacedDigit()
    }
    
    func claim(
        for player: SetGame.Player
    ) -> some View {
        
        Button {
            themedGame
                .claim(by: player)
        } label: {
            Image(
                systemName: "exclamationmark.circle.fill"
            )
            .font(.largeTitle)
        }
        .disabled(
            !themedGame.canClaim
            || themedGame.hasPenalty(for: player)
        )
    }
    
    // MARK: - Common Controls
    
    @ViewBuilder
    func commonControls(
        for player: SetGame.Player
    ) -> some View {
        
        deal
        reset
        score(for: player)
    }
    
    var deal: some View {
        Button {
            themedGame.deal()
        } label: {
            Image(
                systemName: "rectangle.stack.fill.badge.plus"
            )
            .font(.largeTitle)
        }
        .disabled(themedGame.deckIsEmpty)
    }
    
    var reset: some View {
        Button {
            themedGame.reset()
        } label: {
            Image(
                systemName: "arrow.counterclockwise.circle.fill"
            )
            .font(.largeTitle)
        }
    }
    
    @ViewBuilder
    func score(
        for player: SetGame.Player
    ) -> some View {
        
        let isDisabled = themedGame.isMatch == true
        || themedGame.isOver
        
        Button {
            themedGame.cheat()
        } label: {
            Text("Score: \(player.score)")
                .font(.title)
        }
        .foregroundStyle(isDisabled ? .black : .blue)
        .disabled(isDisabled)
    }
    
    struct Constants {
        static let aspectRatio: CGFloat = 2/3
        static let minWidth: CGFloat = 72
        static let cardPadding: CGFloat = 4
    }
}

#Preview {
    SetGameView(themedGame: .init())
}
