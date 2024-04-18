//
//  Theme+UI.swift
//  Set
//
//  Created by Denis Avdeev on 17.04.2024.
//

import SwiftUI

extension Theme.Color {
    
    var ui: Color {
        switch self {
        case .red:
            .red
        case .green:
            .green
        case .purple:
            .blue
        }
    }
}

struct Diamond: Shape {
    
    func path(
        in rect: CGRect
    ) -> Path {
        var path = Path()
        
        path.move(to: .init(x: rect.midX, y: .zero))
        path.addLine(to: .init(x: rect.maxX, y: rect.midY))
        path.addLine(to: .init(x: rect.midX, y: rect.maxY))
        path.addLine(to: .init(x: .zero, y: rect.midY))
        path.closeSubpath()
        
        return path
    }
}

extension Shape {
    
    @ViewBuilder
    func shading(
        _ shading: Theme.Shading
    ) -> some View {
        
        switch shading {
        case .solid:
            self
        case .striped:
            opacity(0.5)
        case .open:
            stroke(lineWidth: 4)
                .padding(4)
        }
    }
}

extension Theme.Shape {
    
    @ViewBuilder
    func ui(
        shading: Theme.Shading
    ) -> some View {
        
        switch self {
        case .diamond:
            Diamond()
                .shading(shading)
        case .squiggle:
            Rectangle()
                .shading(shading)
        case .oval:
            Ellipse()
                .shading(shading)
        }
    }
}

extension SetGameViewModel.ThemedSetGame.Card {
    
    func backgroundColor(
        isMatch: Bool?
    ) -> SwiftUI.Color {
        
        if isChosen {
            switch isMatch {
            case .some(true):
                .green
            case .some(false):
                .red
            case .none:
                .yellow
            }
        } else {
            .clear
        }
    }
}
