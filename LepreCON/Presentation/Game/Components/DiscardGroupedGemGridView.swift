//
// DiscardGroupedGemGridView.swift
// LepreCON
//
// Compact scrollable grid of grouped discard gem kinds (image + label + count).
// Viewing only — optional selection hook reserved for future retrieval.
//

import SwiftUI

/// Grouped-by-`GemKind` discard grid. One cell per kind, not per individual gem.
struct DiscardGroupedGemGridView: View {
    let gemCounts: [GemCountDisplayItem]
    let gemSize: CGFloat
    let cellMinHeight: CGFloat
    /// Fixed column count from content-sized panel metrics.
    var columnCount: Int = 1
    /// When false, the full grid is shown without a vertical ScrollView.
    var allowsScrolling: Bool = false
    var emptyMessage: String = "No discarded gems"
    /// Reserved for future retrieval; unused while viewing-only.
    var isSelectionEnabled: Bool = false
    var onSelectKind: (GemKind) -> Void = { _ in }

    private var gridColumns: [GridItem] {
        let count = max(columnCount, 1)
        return Array(
            repeating: GridItem(
                .flexible(minimum: 36),
                spacing: BoardLayoutMetrics.discardGridSpacing
            ),
            count: count
        )
    }

    var body: some View {
        Group {
            if gemCounts.isEmpty {
                Text(emptyMessage)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(HUDFantasyText.labelColor)
                    .hudReadableShadow()
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .accessibilityLabel(emptyMessage)
            } else if allowsScrolling {
                ScrollView {
                    gemGrid
                }
            } else {
                gemGrid
            }
        }
    }

    private var gemGrid: some View {
        LazyVGrid(
            columns: gridColumns,
            alignment: .center,
            spacing: BoardLayoutMetrics.discardGridSpacing
        ) {
            ForEach(gemCounts) { item in
                if isSelectionEnabled {
                    Button {
                        onSelectKind(item.kind)
                    } label: {
                        DiscardGroupedGemCell(
                            item: item,
                            gemSize: gemSize,
                            cellMinHeight: cellMinHeight
                        )
                    }
                    .buttonStyle(.plain)
                } else {
                    DiscardGroupedGemCell(
                        item: item,
                        gemSize: gemSize,
                        cellMinHeight: cellMinHeight
                    )
                }
            }
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 0)
    }
}

/// Dense grouped discard cell: gem identity + overlaid count (and special label).
struct DiscardGroupedGemCell: View {
    let item: GemCountDisplayItem
    let gemSize: CGFloat
    let cellMinHeight: CGFloat

    var body: some View {
        ZStack {
            GemView(imageName: item.imageName, size: gemSize)

            if let label = item.kind.handGemOverlayLabel {
                Text(label)
                    .font(.system(size: 7, weight: .heavy))
                    .foregroundStyle(BoardStyle.hudValue)
                    .padding(.horizontal, 2)
                    .padding(.vertical, 0.5)
                    .background(Color.black.opacity(0.45), in: Capsule())
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .padding(1)
            }

            Text("×\(item.count)")
                .font(.system(size: 9, weight: .bold, design: .rounded))
                .foregroundStyle(BoardStyle.hudValue)
                .padding(.horizontal, 3)
                .padding(.vertical, 0.5)
                .background(Color.black.opacity(0.5), in: Capsule())
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                .padding(1)
        }
        .frame(width: gemSize, height: max(cellMinHeight, gemSize))
        .frame(maxWidth: .infinity, minHeight: cellMinHeight)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(item.displayName) \(item.count)")
    }
}

#Preview("Discard grouped grid") {
    DiscardGroupedGemGridView(
        gemCounts: GemCountDisplayBuilder.displayOrder.map {
            GemCountDisplayItem(kind: $0, count: 2)
        },
        gemSize: GameScreenLayout.handTrayGridGemSize * 0.60,
        cellMinHeight: GameScreenLayout.handTrayGridGemSize * 0.60,
        columnCount: 6,
        allowsScrolling: false
    )
    .frame(width: 300, height: 90)
    .background(GemTrayPanelChrome.background)
}
