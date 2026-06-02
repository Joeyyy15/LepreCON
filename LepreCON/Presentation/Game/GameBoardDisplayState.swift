//
// GameBoardDisplayState.swift
// LepreCON
//
// Maps a GameSession into presentation-friendly board data for SwiftUI.
// Domain cup indices stay in circle order; this file defines how they appear on screen.
//

import Foundation

/// One gem shown in the UI with a stable identity for tap actions.
struct GemDisplayItem: Identifiable, Equatable {
    let id: UUID
    let imageName: String
    let kind: GemKind
}

/// One cup or pot slot on the board with gems and highlight state.
struct CupSlotDisplay: Equatable, Identifiable {
    let id: UUID
    let cupIndex: Int
    let gemItems: [GemDisplayItem]
    let isHighlighted: Bool
    let scoring: CupScoringDisplay

    var gemImageNames: [String] {
        gemItems.map(\.imageName)
    }
}

/// One rainbow lane (colored cup) in the top row of the board.
struct RainbowLaneDisplay: Equatable, Identifiable {
    let id: UUID
    let cupIndex: Int
    let laneColor: RainbowLaneColor
    let gemItems: [GemDisplayItem]
    let isHighlighted: Bool
    let scoring: CupScoringDisplay

    var gemImageNames: [String] {
        gemItems.map(\.imageName)
    }
}

/// One slot in the bottom row (cloud or pot), in left-to-right screen order.
struct BottomRowSlotDisplay: Equatable, Identifiable {
    enum Kind: Equatable {
        case cloud(number: Int)
        case pot
    }

    let cupSlot: CupSlotDisplay
    let kind: Kind

    var id: UUID { cupSlot.id }
}

/// Snapshot of everything GameBoardView and the game controls need to render.
struct GameBoardDisplayState: Equatable {
    let rainbowLanes: [RainbowLaneDisplay]
    /// Bottom row left → right per rulebook image: cloud2, cloud1, pot, cloud3, cloud4.
    let bottomRow: [BottomRowSlotDisplay]
    let handGems: [GemDisplayItem]
    let discardGems: [GemDisplayItem]
    let currentRoll: Int?
    let canRollD12: Bool
    let canPlaceFromHand: Bool
    let isTurnPlacementComplete: Bool
    /// Cups with pending score options the player can confirm (after placement ends).
    let pendingScoringCups: [CupScoringRowDisplay]

    /// Domain cup index → cloud label (1–4) for white/cloud cups only.
    static func cloudNumber(forCupIndex index: Int) -> Int? {
        switch index {
        case 0: return 1
        case 1: return 2
        case 8: return 3
        case 9: return 4
        default: return nil
        }
    }

    /// Builds display state from the live game session.
    static func from(session: GameSession) -> GameBoardDisplayState {
        let cups = session.cups
        let highlightIndex = GameTurnEngine.canPlaceFromHand(in: session)
            ? session.nextPlacementCupIndex
            : nil

        func cupSlot(at index: Int) -> CupSlotDisplay {
            let cup = cups[index]
            return CupSlotDisplay(
                id: cup.id,
                cupIndex: index,
                gemItems: cup.gems.map { GemDisplayItem(gem: $0) },
                isHighlighted: highlightIndex == index,
                scoring: scoringDisplay(forCupIndex: index, session: session)
            )
        }

        func rainbowLane(cupIndex: Int, color: RainbowLaneColor) -> RainbowLaneDisplay {
            let cup = cups[cupIndex]
            return RainbowLaneDisplay(
                id: cup.id,
                cupIndex: cupIndex,
                laneColor: color,
                gemItems: cup.gems.map { GemDisplayItem(gem: $0) },
                isHighlighted: highlightIndex == cupIndex,
                scoring: scoringDisplay(forCupIndex: cupIndex, session: session)
            )
        }

        // Visual bottom row matches setup diagram (domain indices in parentheses):
        // cloud2 (1) | cloud1 (0) | pot (10) | cloud4 (9) | cloud3 (8)
        //
        // Important:
        // The visual order is different from the logical placement order.
        // Logical placement still follows domain/circle order:
        // cloud1 → cloud2 → red → orange → yellow → green → blue → purple → cloud3 → cloud4 → pot
        let bottomRow: [BottomRowSlotDisplay] = [
            BottomRowSlotDisplay(cupSlot: cupSlot(at: 1), kind: .cloud(number: 2)),
            BottomRowSlotDisplay(cupSlot: cupSlot(at: 0), kind: .cloud(number: 1)),
            BottomRowSlotDisplay(cupSlot: cupSlot(at: GameSetup.potOfGoldCupIndex), kind: .pot),
            BottomRowSlotDisplay(cupSlot: cupSlot(at: 9), kind: .cloud(number: 4)),
            BottomRowSlotDisplay(cupSlot: cupSlot(at: 8), kind: .cloud(number: 3))
        ]

        let pendingScoringCups = session.pendingScoreChoices.map { choice in
            CupScoringRowDisplay(
                cupIndex: choice.cupIndex,
                cupLabel: cupLabel(forCupIndex: choice.cupIndex, cups: cups),
                pendingOptions: choice.candidates.map { PendingScoreOptionDisplay(candidate: $0) }
            )
        }

        return GameBoardDisplayState(
            rainbowLanes: [
                rainbowLane(cupIndex: 2, color: .red),
                rainbowLane(cupIndex: 3, color: .orange),
                rainbowLane(cupIndex: 4, color: .yellow),
                rainbowLane(cupIndex: 5, color: .green),
                rainbowLane(cupIndex: 6, color: .blue),
                rainbowLane(cupIndex: 7, color: .purple)
            ],
            bottomRow: bottomRow,
            handGems: session.gemsInHand.map { GemDisplayItem(gem: $0) },
            discardGems: session.discardPile.map { GemDisplayItem(gem: $0) },
            currentRoll: session.currentRoll,
            canRollD12: GameTurnEngine.canRollD12(in: session),
            canPlaceFromHand: GameTurnEngine.canPlaceFromHand(in: session),
            isTurnPlacementComplete: session.isTurnPlacementComplete,
            pendingScoringCups: pendingScoringCups
        )
    }

    /// Maps domain scoring state for one cup into presentation models.
    static func scoringDisplay(forCupIndex index: Int, session: GameSession) -> CupScoringDisplay {
        let cup = session.cups[index]

        if let completion = cup.completion {
            return CupScoringDisplay(
                pendingOptions: [],
                completedCaption: "Scored \(completion.scoredColor.scoringDisplayName)"
            )
        }

        if let pending = session.pendingScoreChoices.first(where: { $0.cupIndex == index }) {
            return CupScoringDisplay(
                pendingOptions: pending.candidates.map { PendingScoreOptionDisplay(candidate: $0) },
                completedCaption: nil
            )
        }

        return .none
    }

    private static func cupLabel(forCupIndex index: Int, cups: [Cup]) -> String {
        guard cups.indices.contains(index) else { return "Cup \(index)" }
        let cup = cups[index]
        if cup.isPotOfGold { return "Pot of Gold" }
        if let cloud = cloudNumber(forCupIndex: index) { return "Cloud \(cloud)" }
        if let color = cup.color { return color.rawValue.capitalized }
        return "Cup \(index)"
    }
}

// MARK: - Gem asset mapping

extension GemDisplayItem {
    init(gem: Gem) {
        id = gem.id
        kind = gem.kind
        imageName = gem.kind.imageAssetName
    }
}

extension GemKind {
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
        // Clear and white are separate gem types; both use the white asset until a clear image exists.
        case .clear: return "gem_white"
        case .pink: return "gem_purple"
        }
    }
}
