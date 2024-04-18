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
        AspectVGrid(
            viewModel.cards,
            aspectRatio: Constants.aspectRatio,
            maxColumns: Constants.maxColumns
        ) {
            CardView(card: $0)
                .padding(Constants.cardPadding)
        }
        .padding()
    }
    
    private struct Constants {
        static let aspectRatio: CGFloat = 2/3
        static let maxColumns = 5
        static let cardPadding: CGFloat = 4
    }
}

#Preview {
    SetGameView(viewModel: .init())
}
