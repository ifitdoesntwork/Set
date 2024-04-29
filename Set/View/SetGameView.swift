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
            themedGame.cards.field,
            aspectRatio: Constants.aspectRatio,
            minWidth: Constants.minWidth
        ) { card in
            
            CardView(
                card: card,
                isMatch: themedGame.isMatch, 
                isFaceUp: card.isFaceUp,
                theme: themedGame.theme
            )
            .padding(Constants.cardPadding)
            .onTapGesture {
                themedGame
                    .choose(card)
            }
        }
    }
    
    func panel(
        for player: SetGame.Player
    ) -> some View {
        
        ZStack {
            stack(for: player)
            
            HStack {
                score(for: player)
                
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
    }
    
    @ViewBuilder
    func stack(
        for player: SetGame.Player
    ) -> some View {
        
        stack(
            of: player.id == themedGame.players[0].id
                ? themedGame.cards.pile
                : themedGame.cards.deck
        )
        .frame(
            width: Constants.minWidth,
            height: Constants.minWidth
            / Constants.aspectRatio
        )
    }
    
    @ViewBuilder
    func stack(
        of cards: [SetGame.Card]
    ) -> some View {
       
        if cards.isEmpty {
            Color.clear
        } else {
            ZStack {
                ForEach(cards) { card in
                    CardView(
                        card: card,
                        isMatch: nil,
                        isFaceUp: card.isFaceUp,
                        theme: themedGame.theme
                    )
                }
            }
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
    
    struct Constants {
        static let aspectRatio: CGFloat = 2/3
        static let minWidth: CGFloat = 72
        static let deckWidth: CGFloat = 48
        static let cardPadding: CGFloat = 4
    }
}

#Preview {
    SetGameView(themedGame: .init())
}
