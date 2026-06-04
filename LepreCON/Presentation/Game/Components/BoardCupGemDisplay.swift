//
// BoardCupGemDisplay.swift
// LepreCON
//
// Shared board gem previews: stacked lane pieces and overlapping cup clusters.
//

import SwiftUI

// MARK: - Lane stack (rainbow)

/// Vertical stack of gem “pieces” in a rainbow lane, bottom-aligned with slight overlap.
struct BoardLaneGemStack: View {
    let items: [GemCountDisplayItem]
    let width: CGFloat
    let height: CGFloat

    /// Tiny inset so gems nearly fill the lane without touching the stroke.
    private var horizontalPadding: CGFloat { 1 }

    private var gemSize: CGFloat {
        let usableWidth = max(0, width - horizontalPadding * 2)
        return usableWidth * 0.97
    }

    private var badgeClearance: CGFloat {
        max(11, gemSize * 0.24)
    }

    private var overlapStep: CGFloat {
        guard items.count > 1 else { return 0 }
        let maxStack = max(0, height - badgeClearance - 2)
        let heavyOverlap = gemSize * 0.62
        let needed = gemSize + heavyOverlap * CGFloat(items.count - 1)
        if needed <= maxStack { return heavyOverlap }

        let mediumOverlap = gemSize * 0.54
        let neededMedium = gemSize + mediumOverlap * CGFloat(items.count - 1)
        if neededMedium <= maxStack { return mediumOverlap }

        return max(4, (maxStack - gemSize) / CGFloat(items.count - 1))
    }

    private var stackHeight: CGFloat {
        guard !items.isEmpty else { return 0 }
        return gemSize + overlapStep * CGFloat(items.count - 1)
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                BoardGemPieceView(
                    item: item,
                    gemSize: gemSize,
                    showsKindLabel: false
                )
                .offset(y: -overlapStep * CGFloat(index))
            }
        }
        .padding(.top, badgeClearance)
        .frame(width: width, height: min(height, stackHeight + badgeClearance), alignment: .bottom)
    }
}

// MARK: - Cup cluster (cloud / pot)

/// Overlapping gem preview for cloud cups and the pot of gold.
struct BoardCupGemCluster: View {
    let items: [GemCountDisplayItem]
    let width: CGFloat
    let height: CGFloat
    var showsKindLabel: Bool = true

    /// Caps how many distinct kinds fan out at full size; extras overlap tighter on top.
    private var previewItems: [GemCountDisplayItem] {
        let limit = 5
        guard items.count > limit else { return items }
        return Array(items.prefix(limit))
    }

    private var gemSize: CGFloat {
        let fit = min(width, height)
        let target = fit * 0.72
        if previewItems.count > 3 {
            return min(max(target, 28), 42)
        }
        return min(max(target, 30), 46)
    }

    var body: some View {
        ZStack {
            ForEach(Array(previewItems.enumerated()), id: \.element.id) { index, item in
                BoardGemPieceView(
                    item: item,
                    gemSize: gemSize,
                    showsKindLabel: showsKindLabel && !item.shortLabel.isEmpty
                )
                .offset(
                    x: horizontalOffset(index: index, count: previewItems.count),
                    y: verticalOffset(index: index, count: previewItems.count)
                )
                .zIndex(Double(index))
            }

            if items.count > previewItems.count {
                BoardGemOverflowBadge(extraCount: items.count - previewItems.count, gemSize: gemSize)
                    .offset(x: gemSize * 0.22, y: -gemSize * 0.28)
                    .zIndex(Double(previewItems.count + 1))
            }
        }
        .frame(width: width, height: height, alignment: .center)
    }

    private func horizontalOffset(index: Int, count: Int) -> CGFloat {
        guard count > 1 else { return 0 }
        let spread = min(gemSize * 0.34, max(6, width * 0.16))
        let centered = CGFloat(index) - (CGFloat(count - 1) / 2)
        return centered * spread
    }

    private func verticalOffset(index: Int, count: Int) -> CGFloat {
        guard count > 1 else { return 0 }
        return -CGFloat(index) * min(gemSize * 0.18, 8)
    }
}

// MARK: - Single piece + count badge

struct BoardGemPieceView: View {
    let item: GemCountDisplayItem
    let gemSize: CGFloat
    var showsKindLabel: Bool = false

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 1) {
                GemView(imageName: item.imageName, size: gemSize)

                if showsKindLabel {
                    Text(item.shortLabel)
                        .font(.system(size: max(7, gemSize * 0.26), weight: .heavy))
                        .foregroundStyle(BoardStyle.hudValue)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
            }

            BoardGemCountBadge(count: item.count, gemSize: gemSize)
                .offset(x: gemSize * 0.05, y: -gemSize * 0.05)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(item.displayName) \(item.count)")
    }
}

struct BoardGemCountBadge: View {
    let count: Int
    let gemSize: CGFloat

    private var fontSize: CGFloat { max(9, min(12, gemSize * 0.32)) }

    var body: some View {
        Text("×\(count)")
            .font(.system(size: fontSize, weight: .bold))
            .foregroundStyle(.white)
            .lineLimit(1)
            .minimumScaleFactor(0.75)
            .padding(.horizontal, 4)
            .padding(.vertical, 2)
            .background(
                Capsule(style: .continuous)
                    .fill(Color.black.opacity(0.78))
            )
            .overlay(
                Capsule(style: .continuous)
                    .stroke(Color.white.opacity(0.4), lineWidth: 0.5)
            )
    }
}

struct BoardGemOverflowBadge: View {
    let extraCount: Int
    let gemSize: CGFloat

    var body: some View {
        Text("+\(extraCount)")
            .font(.system(size: max(8, gemSize * 0.28), weight: .heavy))
            .foregroundStyle(.white)
            .padding(.horizontal, 4)
            .padding(.vertical, 2)
            .background(Capsule(style: .continuous).fill(Color.black.opacity(0.75)))
    }
}

#Preview("Lane stack") {
    BoardLaneGemStack(
        items: [
            GemCountDisplayItem(kind: .red, count: 3),
            GemCountDisplayItem(kind: .gold, count: 1)
        ],
        width: 40,
        height: 180
    )
    .padding()
    .background(Color.green.opacity(0.3))
}

#Preview("Cup cluster") {
    BoardCupGemCluster(
        items: [
            GemCountDisplayItem(kind: .white, count: 2),
            GemCountDisplayItem(kind: .black, count: 1)
        ],
        width: 62,
        height: 52
    )
    .padding()
    .background(Color.gray.opacity(0.2))
}
