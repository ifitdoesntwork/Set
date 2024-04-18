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
        VStack {
            CardView(card: viewModel.card)
        }
        .padding()
    }
}

#Preview {
    SetGameView(viewModel: .init())
}
