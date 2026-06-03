//
// DiscardPileView.swift
// LepreCON
//
// Discard pile title and grouped gem counts.
//

import SwiftUI

struct DiscardPileView: View {
    let gemCounts: [GemCountDisplayItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Discard Pile")
                .font(.headline)

            if gemCounts.isEmpty {
                Text("Empty")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                LazyVGrid(
                    columns: [GridItem(.adaptive(minimum: 72, maximum: 120), spacing: 8)],
                    alignment: .leading,
                    spacing: 8
                ) {
                    ForEach(gemCounts) { item in
                        GemCountBadgeView(item: item, style: .compact(gemSize: 28))
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
