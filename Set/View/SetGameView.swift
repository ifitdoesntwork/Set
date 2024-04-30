//
//  SetGameView.swift
//  Set
//
//  Created by Denis Avdeev on 17.04.2024.
//

import SwiftUI

struct SetGameView: View {
    @ObservedObject var themedGame: ThemedGame
    @State private var pileIds = [SetGame.Card.ID]()
    
    var body: some View {
        
        panel(for: themedGame.players[0])
            .rotationEffect(.radians(.pi))
        
        cards
            .padding(.horizontal)
        
        panel(for: themedGame.players[1])
    }
    
    @Namespace private var discarding
}

private extension SetGameView {
    
    var field: [SetGame.Card] {
        themedGame.cards
            .filter {
                !(
                    pileIds.contains($0.id)
                    || themedGame.cards.deck
                        .map(\.id)
                        .contains($0.id)
                )
            }
    }
    
    var cards: some View {
        
        AspectVGrid(
            field,
            aspectRatio: Constants.aspectRatio,
            minWidth: Constants.minWidth
        ) { card in
            
            CardView(
                card: card,
                isMatch: themedGame.isMatch,
                isFaceUp: card.isFaceUp,
                theme: themedGame.theme
            )
            .matchedGeometryEffect(
                id: card.id,
                in: discarding
            )
            .transition(.asymmetric(
                insertion: .identity,
                removal: .identity
            ))
            .padding(Constants.cardPadding)
            .onTapGesture {
                
                let oldPileIds = themedGame.cards.pile
                    .map(\.id)
                
                themedGame
                    .choose(card)
                
                themedGame.cards.pile
                    .filter { !oldPileIds.contains($0.id) }
                    .forEach { card in
                        withAnimation {
                            pileIds.append(card.id)
                        }
                    }
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
    
    var pile: [SetGame.Card] {
        pileIds
            .compactMap { id in
                themedGame.cards
                    .first { $0.id == id }
            }
    }
    
    func stack(
        for player: SetGame.Player
    ) -> some View {
        
        stack(
            of: player.id == themedGame.players[0].id
                ? pile
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
                    .matchedGeometryEffect(
                        id: card.id,
                        in: discarding
                    )
                    .transition(.asymmetric(
                        insertion: .identity,
                        removal: .identity
                    ))
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
