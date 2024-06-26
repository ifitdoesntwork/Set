//
//  AspectVGrid.swift
//  Memorize
//
//  Created by CS193p Instructor on 4/24/23.
//

import SwiftUI

struct AspectVGrid<Item: Identifiable, ItemView: View>: View {
    private let items: [Item]
    private let count: Int
    private let aspectRatio: CGFloat
    private let minWidth: CGFloat
    private let content: (Item) -> ItemView
    
    init(
        _ items: [Item],
        count: Int,
        aspectRatio: CGFloat = 1,
        minWidth: CGFloat = .zero,
        @ViewBuilder content: @escaping (Item) -> ItemView
    ) {
        self.items = items
        self.count = count
        self.aspectRatio = aspectRatio
        self.minWidth = minWidth
        self.content = content
    }
    
    var body: some View {
        
        GeometryReader { geometry in
            
            let gridItemSize = max(
                gridItemWidthThatFits(
                    count: max(count, items.count),
                    size: geometry.size,
                    atAspectRatio: aspectRatio
                ),
                minWidth
            )
            
            ScrollView {
                LazyVGrid(
                    columns: [GridItem(
                        .adaptive(minimum: gridItemSize),
                        spacing: 0
                    )],
                    spacing: 0
                ) {
                    ForEach(items) { item in
                        content(item)
                            .aspectRatio(
                                aspectRatio,
                                contentMode: .fit
                            )
                    }
                }
                .frame(minHeight: geometry.size.height)
            }
        }
    }
    
    private func gridItemWidthThatFits(
        count: Int,
        size: CGSize,
        atAspectRatio aspectRatio: CGFloat
    ) -> CGFloat {
        
        let count = CGFloat(count)
        var columnCount = 1.0
        
        repeat {
            let width = size.width / columnCount
            let height = width / aspectRatio
            
            let rowCount = (count / columnCount)
                .rounded(.up)
            
            if rowCount * height < size.height {
                return (size.width / columnCount)
                    .rounded(.down)
            }
            
            columnCount += 1
        } while columnCount < count
        
        return min(
            size.width / count,
            size.height * aspectRatio
        )
        .rounded(.down)
    }
}
