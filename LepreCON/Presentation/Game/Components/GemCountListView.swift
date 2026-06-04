//
// GemCountListView.swift
// LepreCON
//
// Compact grouped gem rows: PNG + optional short label + count.
//

import SwiftUI

/// Size preset for grouped gem badges on different board areas.
enum GemCountBadgeStyle: Equatable {
    /// Larger badges for rainbow lanes (more vertical space).
    case largeLane(laneWidth: CGFloat)
    /// Smaller badges for clouds, pot, and discard.
    case compact(gemSize: CGFloat)
    /// Compact tappable badges for the player's hand.
    case hand(gemSize: CGFloat)

    var gemSize: CGFloat {
        switch self {
        case .largeLane(let laneWidth):
            return min(laneWidth * 0.34, 15)
        case .compact(let size), .hand(let size):
            return size
        }
    }

    var labelFontSize: CGFloat {
        switch self {
        case .largeLane:
            return 8
        case .compact:
            return 8
        case .hand:
            return 10
        }
    }

    var countFontSize: CGFloat {
        switch self {
        case .largeLane:
            return 9
        case .compact:
            return 9
        case .hand:
            return 11
        }
    }

    var rowSpacing: CGFloat {
        switch self {
        case .largeLane:
            return 3
        case .compact, .hand:
            return 2
        }
    }
}

struct GemCountBadgeView: View {
    let item: GemCountDisplayItem
    let style: GemCountBadgeStyle
    var showsShortLabel: Bool = true

    var body: some View {
        HStack(spacing: 3) {
            GemView(imageName: item.imageName, size: style.gemSize)

            if showsShortLabel, !item.shortLabel.isEmpty {
                Text(item.shortLabel)
                    .font(.system(size: style.labelFontSize, weight: .bold))
                    .foregroundStyle(.primary)
            }

            Text("×\(item.count)")
                .font(.system(size: style.countFontSize, weight: .semibold))
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
    let style: GemCountBadgeStyle
    var showsShortLabel: Bool = true

    var body: some View {
        VStack(alignment: .leading, spacing: style.rowSpacing) {
            ForEach(items) { item in
                GemCountBadgeView(
                    item: item,
                    style: style,
                    showsShortLabel: showsShortLabel
                )
            }
        }
    }
}

#Preview("Gem Count List") {
    VStack(spacing: 16) {
        GemCountListView(
            items: [
                GemCountDisplayItem(kind: .red, count: 3),
                GemCountDisplayItem(kind: .gold, count: 2)
            ],
            style: .largeLane(laneWidth: 42)
        )
        GemCountListView(
            items: [GemCountDisplayItem(kind: .clear, count: 1)],
            style: .compact(gemSize: 18)
        )
    }
    .padding()
    .background(.gray.opacity(0.2))
}
