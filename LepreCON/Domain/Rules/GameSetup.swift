//
// GameSetup.swift
// LepreCON
//
// Physical setup rules from the rulebook: gem counts, cup layout, and placing one
// non-black gem in each cup before play. Magic, turns, and scoring are not here.
//

import Foundation

/// Describes one board position when building cups (colored cup or pot of gold).
enum BoardSlotDefinition: Equatable {
    case colored(CupColor)
    case potOfGold
}

enum GameSetup {

    /// Total gems in a standard LepreCON game.
    static let totalGemCount = 93

    /// Eleven board positions in circle order:
    /// cloud, cloud, red, orange, yellow, green, blue, purple, cloud, cloud, pot of gold.
    static let boardSlotLayout: [BoardSlotDefinition] = [
        .colored(.white), .colored(.white),
        .colored(.red), .colored(.orange), .colored(.yellow),
        .colored(.green), .colored(.blue), .colored(.purple),
        .colored(.white), .colored(.white),
        .potOfGold
    ]

    /// Index of the pot of gold cup in `boardSlotLayout` (last position).
    static let potOfGoldCupIndex = 10

    /// First placement cup: first cloud immediately after the pot (index 0 in board order).
    static let firstPlacementCupIndex = 0

    /// How many of each gem kind belong in a full game before any are placed in cups.
    static let standardGemCounts: [GemKind: Int] = [
        .red: 12,
        .orange: 12,
        .yellow: 12,
        .green: 12,
        .blue: 12,
        .purple: 12,
        .gold: 9,
        .black: 3,
        .white: 3,
        .clear: 3,
        .pink: 3
    ]

    /// Creates the 11 board cups in rulebook order, empty and ready for setup gems.
    static func makePhysicalCups() -> [Cup] {
        boardSlotLayout.map { slot in
            switch slot {
            case .colored(let color):
                return Cup(color: color)
            case .potOfGold:
                return Cup(isPotOfGold: true)
            }
        }
    }

    /// Builds the full 93-gem bag with rulebook counts. Gems are not shuffled yet.
    static func makeFullGemBag() -> [Gem] {
        var gems: [Gem] = []
        for kind in GemKind.allCases {
            let count = standardGemCounts[kind, default: 0]
            for _ in 0..<count {
                gems.append(Gem(kind: kind))
            }
        }
        return gems
    }

    /// Mixes the bag, then places exactly one non-black gem in each cup.
    /// Black gems drawn during setup are returned to the bag and redrawn.
    static func placeSetupGemsInCups(cups: inout [Cup], gemsInBag: inout [Gem]) {
        gemsInBag.shuffle()

        for index in cups.indices {
            let gem = drawNonBlackGem(from: &gemsInBag)
            cups[index].gems = [gem]
        }
    }

    /// Draws from the bag until a non-black gem is found. Black gems are put back for redraw.
    private static func drawNonBlackGem(from bag: inout [Gem]) -> Gem {
        while true {
            guard !bag.isEmpty else {
                fatalError("Setup requires a non-black gem in the bag but the bag is empty.")
            }
            let drawIndex = Int.random(in: 0..<bag.count)
            let gem = bag.remove(at: drawIndex)
            if gem.kind != .black {
                return gem
            }
            bag.append(gem)
        }
    }
}
