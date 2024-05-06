//
//  SetGameView.swift
//  Set
//
//  Created by Denis Avdeev on 17.04.2024.
//

import SwiftUI

struct SetGameView: View {
    @ObservedObject var themedGame: ThemedGame
    @State private var fieldIds = [SetGame.Card.ID]()
    @State private var pileIds = [SetGame.Card.ID]()
    @State private var faceUpIds = [SetGame.Card.ID]()
    
    var body: some View {
        
        panel(for: themedGame.players[0])
            .rotationEffect(.radians(.pi))
        
        cards
            .padding(.horizontal)
            .onTapGesture {
                withAnimation {
                    fieldIds
                        .shuffle()
                }
            }
        
        panel(for: themedGame.players[1])
            .onAppear {
                updateUI()
            }
    }
    
    @Namespace private var dealing
}

private extension SetGameView {
    
    var cards: some View {
        
        AspectVGrid(
            cards(from: fieldIds), 
            count: themedGame.cards.field.count,
            aspectRatio: Constants.aspectRatio,
            minWidth: Constants.minWidth
        ) { card in
            
            CardView(card: themedCard(card))
                .matchedGeometryEffect(
                    id: card.id,
                    in: dealing
                )
                .padding(Constants.cardPadding)
                .onTapGesture {
                    withAnimation {
                        themedGame.choose(card)
                    }
                    
                    updateUI()
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
    
    func stack(
        for player: SetGame.Player
    ) -> some View {
        
        let isFirstPlayer = player.id == themedGame.players[0].id
        
        return stack(
            of: isFirstPlayer
                ? cards(from: pileIds)
                : themedGame.cards.deck + themedGame.cards.field
                    .filter { !fieldIds.contains($0.id) }
        )
        .frame(
            width: Constants.minWidth,
            height: Constants.minWidth / Constants.aspectRatio
        )
        .onTapGesture {
            handleStackTap(isDealing: !isFirstPlayer)
        }
    }
    
    @ViewBuilder
    func stack(
        of cards: [SetGame.Card]
    ) -> some View {
       
        if cards.isEmpty {
            Rectangle()
                .foregroundStyle(.background)
        } else {
            ZStack {
                ForEach(cards) { card in
                    CardView(card: themedCard(card))
                        .matchedGeometryEffect(
                            id: card.id,
                            in: dealing
                        )
                }
            }
        }
    }
    
    @ViewBuilder
    func score(
        for player: SetGame.Player
    ) -> some View {
        
        let isDisabled = isMatch || themedGame.isOver
        
        Button {
            withAnimation {
                themedGame.cheat()
            }
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

private extension SetGameView {
    
    var isMatch: Bool {
        themedGame.isMatch == true
    }
    
    func themedCard(
        _ card: SetGame.Card
    ) -> ThemedCard {
        
        themedGame.card(
            card,
            isFaceUp: faceUpIds
                .contains(card.id)
        )
    }
    
    func cards(
        from ids: [SetGame.Card.ID]
    ) -> [SetGame.Card] {
        
        ids
            .compactMap { id in
                themedGame.cards
                    .first { $0.id == id }
            }
    }
    
    func handleStackTap(
        isDealing: Bool
    ) {
        let matchIndices = isDealing && isMatch
            ? themedGame.cards.selected
                .compactMap { card in
                    fieldIds
                        .firstIndex { $0 == card.id }
                }
            : []
        
        withAnimation {
            if isDealing {
                themedGame.deal()
            } else {
                themedGame.reset()
                fieldIds.removeAll()
                pileIds.removeAll()
            }
        }
        
        if !isDealing {
            faceUpIds.removeAll()
        }
        
        updateUI(
            insertionIndices: matchIndices
        )
    }
    
    func updateUI(
        insertionIndices: [Int] = []
    ) {
        let indices = insertionIndices
            .sorted()
        
        pileIds.update(
            from: themedGame.cards.pile
        ) {
            fieldIds.remove($1)
            pileIds.append($1)
        }
        
        fieldIds.update(
            from: themedGame.cards.field
        ) {
            fieldIds.insert(
                $1,
                at: $0 < indices.count
                    ? indices[$0]
                    : fieldIds.count
            )
        }
        
        faceUpIds.update(
            from: themedGame.cards.field,
            initialDelay: 0.5
        ) {
            faceUpIds.append($1)
        }
    }
}

private extension Array where Element: Equatable {
    
    mutating func remove(_ element: Element) {
        
        firstIndex { $0 == element }
            .map { _ = remove(at: $0) }
    }
}

private extension Array where Element == SetGame.Card.ID {
    
    func update(
        from cards: [SetGame.Card],
        initialDelay: TimeInterval = 0,
        using closure: (Int, Element) -> Void
    ) {
        cards
            .filter { !contains($0.id) }
            .indexed()
            .forEach { index, card in
                withAnimation(
                    .easeInOut(duration: 0.8)
                    .delay(
                        initialDelay
                        + TimeInterval(index) * 0.1
                    )
                ) {
                    closure(index, card.id)
                }
            }
    }
}

#Preview {
    SetGameView(themedGame: .init())
}
