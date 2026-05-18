//
// GameSessionFactory.swift
// LepreCON
//
// Factory Pattern: this type is responsible for creating a fully configured GameSession.
// Callers (e.g. a view model later) ask for a new game without knowing every setup step.
// That keeps object construction out of SwiftUI views and centralizes new-game defaults here.
//

import Foundation

/// Builds new `GameSession` values with players, cups, and a gem bag ready for setup.
struct GameSessionFactory {

    /// Creates a new game in the setup phase from the given player names.
    /// Does not apply full rules, randomization, or persistence yet.
    func makeNewGame(playerNames: [String]) -> GameSession {
        let players = playerNames.map { Player(name: $0) }
        let cups = makeDefaultCups()
        let gemsInBag = makeDefaultGemBag()

        return GameSession(
            phase: .setup,
            players: players,
            currentPlayerIndex: 0,
            cups: cups,
            gemsInBag: gemsInBag,
            unicornCupID: nil
        )
    }

    // MARK: - Private setup helpers

    /// One cup per board color plus the Pot of Gold. Cups start empty.
    private func makeDefaultCups() -> [Cup] {
        var cups = CupColor.allCases.map { color in
            Cup(color: color)
        }
        cups.append(Cup(isPotOfGold: true))
        return cups
    }

    /// A fixed, non-random gem bag for now. Counts can be tuned when full rules are added.
    private func makeDefaultGemBag() -> [Gem] {
        var gems: [Gem] = []

        let rainbowKinds: [GemKind] = [.red, .orange, .yellow, .green, .blue, .purple]
        for kind in rainbowKinds {
            for _ in 0..<5 {
                gems.append(Gem(kind: kind))
            }
        }

        let specialKinds: [GemKind] = [.white, .gold, .black, .clear, .pink]
        for kind in specialKinds {
            gems.append(Gem(kind: kind))
        }

        return gems
    }
}
