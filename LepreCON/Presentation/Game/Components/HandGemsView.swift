//
// HandGemsView.swift
// LepreCON
//
// Grouped, tappable hand gem counts. Tap a kind to place one gem of that type.
//

import SwiftUI

struct HandGemsView: View {
    let gemCounts: [GemCountDisplayItem]
    var canPlace: Bool = false
    var onTapKind: (GemKind) -> Void = { _ in }

    private let columns = [
        GridItem(.adaptive(minimum: 84, maximum: 110), spacing: 8)
    ]

    var body: some View {
        LazyVGrid(columns: columns, alignment: .leading, spacing: 8) {
            ForEach(gemCounts) { item in
                Button {
                    onTapKind(item.kind)
                } label: {
                    GemCountBadgeView(item: item, style: .hand(gemSize: 26))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(Color.white.opacity(0.14))
                        )
                }
                .buttonStyle(.plain)
                .disabled(!canPlace)
                .accessibilityLabel("Place \(item.displayName), \(item.count) in hand")
            }
        }
    }
}

#Preview("Hand Gems") {
    HandGemsView(
        gemCounts: [
            GemCountDisplayItem(kind: .red, count: 3),
            GemCountDisplayItem(kind: .gold, count: 1),
            GemCountDisplayItem(kind: .clear, count: 2)
        ],
        canPlace: true,
        onTapKind: { _ in }
    )
    .padding()
}
