//
// GemCountDisplayItem.swift
// LepreCON
//
// Presentation-only grouped gem counts for board cups and discard.
//

import Foundation

/// One gem kind and how many appear in a cup, lane, cloud, or pot.
struct GemCountDisplayItem: Identifiable, Equatable {
    let kind: GemKind
    let imageName: String
    let count: Int
    let shortLabel: String
    let displayName: String

    var id: GemKind { kind }

    init(kind: GemKind, count: Int) {
        self.kind = kind
        self.count = count
        self.imageName = kind.imageAssetName
        self.shortLabel = kind.gemCountShortLabel
        self.displayName = kind.gemCountDisplayName
    }
}

enum GemCountDisplayBuilder {

    /// Stable order for grouped rows on the board.
    static let displayOrder: [GemKind] = [
        .red, .orange, .yellow, .green, .blue, .purple,
        .white, .gold, .clear, .pink, .black
    ]

    /// Groups gems by `GemKind` (not asset name) for compact cup/lane display.
    static func groupedCounts(from gems: [Gem]) -> [GemCountDisplayItem] {
        var counts: [GemKind: Int] = [:]
        for gem in gems {
            counts[gem.kind, default: 0] += 1
        }

        return displayOrder.compactMap { kind in
            guard let count = counts[kind], count > 0 else { return nil }
            return GemCountDisplayItem(kind: kind, count: count)
        }
    }
}

// MARK: - GemKind presentation labels

extension GemKind {

    var gemCountDisplayName: String {
        switch self {
        case .red, .orange, .yellow, .green, .blue, .purple:
            return rawValue.capitalized
        case .white: return "White"
        case .gold: return "Gold"
        case .clear: return "Clear"
        case .pink: return "Pink"
        case .black: return "Black"
        }
    }

    /// Short tag shown beside the PNG when kinds share an asset image.
    var gemCountShortLabel: String {
        switch self {
        case .red, .orange, .yellow, .green, .blue, .purple:
            return ""
        case .white: return "W"
        case .gold: return "Au"
        case .clear: return "C"
        case .pink: return "Pk"
        case .black: return "Poop"
        }
    }

    /// Asset catalog image name for this gem kind.
    var imageAssetName: String {
        switch self {
        case .red: return "gem_red"
        case .orange: return "gem_orange"
        case .yellow: return "gem_yellow"
        case .green: return "gem_green"
        case .blue: return "gem_blue"
        case .purple: return "gem_purple"
        case .white: return "gem_white"
        case .black: return "gem_black"
        case .gold: return "gem_yellow"
        case .clear: return "gem_white"
        case .pink: return "gem_purple"
        }
    }
}
