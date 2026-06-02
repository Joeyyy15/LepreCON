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

    /// D12 roll that means discard during unicorn setup (must be rerolled).
    static let unicornDiscardRoll = 12

    /// Valid D12 unicorn placement rolls (1–11). Roll 12 is discard.
    static let unicornPlacementRollRange = 1...11

    /// First placement cup: first cloud immediately after the pot (index 0 in board order).
    static let firstPlacementCupIndex = 0

    /// How many of each gem kind belong in a full game before any are placed in cups.
    /// Includes 3 white and 3 clear as separate types (93 gems total).
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
    ///
    /// Black gems are never left in cups during setup. If a black gem is drawn,
    /// it goes back into the bag and another gem is drawn. All 3 black gems stay
    /// available in the bag for normal play after setup finishes.
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

    // MARK: - Unicorn setup

    /// Cup indices where the unicorn may be placed (every cup except Pot of Gold).
    static func validUnicornCupIndices(cups: [Cup]) -> [Int] {
        cups.indices.filter { !cups[$0].isPotOfGold }
    }

    /// Maps a D12 unicorn placement roll to a cup index.
    ///
    /// Rolls 1–10 map to board indices 0–9. Roll 11 would land on the pot (index 10) and is invalid.
    /// Roll 12 is discard and is invalid. Returns nil when the roll must be rerolled.
    static func unicornCupIndex(forPlacementRoll roll: Int, cups: [Cup]) -> Int? {
        guard unicornPlacementRollRange.contains(roll) else { return nil }

        let candidateIndex = roll - 1
        guard cups.indices.contains(candidateIndex), !cups[candidateIndex].isPotOfGold else {
            return nil
        }
        return candidateIndex
    }

    /// Assigns the unicorn using rulebook D12 placement (1–11 valid, 12 reroll, never on pot).
    static func assignUnicornCupIndex(
        cups: [Cup],
        randomRoll: () -> Int = { Int.random(in: 1...12) }
    ) -> Int {
        while true {
            let roll = randomRoll()
            if let index = unicornCupIndex(forPlacementRoll: roll, cups: cups) {
                return index
            }
        }
    }
}
