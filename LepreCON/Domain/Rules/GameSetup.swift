//
// GameSetup.swift
// LepreCON
//
// Physical setup rules from the rulebook: gem counts, cup layout, and placing one
// non-black gem in each cup before play. Magic, turns, and scoring are not here.
//

import Foundation

enum GameSetup {

    /// Total gems in a standard LepreCON game.
    static let totalGemCount = 93

    /// Eleven cups in circle order (setup diagram): White, White, Red, Orange, Yellow,
    /// Green, Blue, Purple, White, White, Black.
    static let physicalCupLayout: [CupColor] = [
        .white, .white,
        .red, .orange, .yellow, .green, .blue, .purple,
        .white, .white,
        .black
    ]

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
        physicalCupLayout.map { Cup(color: $0) }
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
