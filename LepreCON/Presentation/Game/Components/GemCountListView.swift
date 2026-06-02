//
// GemCountListView.swift
// LepreCON
//
// Compact grouped gem rows: PNG + optional short label + count.
//

import SwiftUI

struct GemCountBadgeView: View {
    let item: GemCountDisplayItem
    let gemSize: CGFloat

    var body: some View {
        HStack(spacing: 3) {
            GemView(imageName: item.imageName, size: gemSize)

            if !item.shortLabel.isEmpty {
                Text(item.shortLabel)
                    .font(.system(size: max(8, gemSize * 0.32), weight: .bold))
                    .foregroundStyle(.primary)
            }

            Text("×\(item.count)")
                .font(.system(size: max(9, gemSize * 0.34), weight: .semibold))
                .foregroundStyle(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(item.displayName) \(item.count)")
    }
}

struct GemCountListView: View {
    let items: [GemCountDisplayItem]
    let gemSize: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            ForEach(items) { item in
                GemCountBadgeView(item: item, gemSize: gemSize)
            }
        }
    }
}

#Preview("Gem Count List") {
    GemCountListView(
        items: [
            GemCountDisplayItem(kind: .red, count: 3),
            GemCountDisplayItem(kind: .gold, count: 2),
            GemCountDisplayItem(kind: .yellow, count: 1),
            GemCountDisplayItem(kind: .clear, count: 1)
        ],
        gemSize: 18
    )
    .padding()
    .background(.gray.opacity(0.2))
}
