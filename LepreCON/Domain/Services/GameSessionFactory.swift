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
    /// Applies physical setup: 11 cups in order, 93 gems, one non-black gem per cup, rest in bag.
    func makeNewGame(playerNames: [String]) -> GameSession {
        let players = playerNames.map { Player(name: $0) }
        var cups = GameSetup.makePhysicalCups()
        var gemsInBag = GameSetup.makeFullGemBag()
        GameSetup.placeSetupGemsInCups(cups: &cups, gemsInBag: &gemsInBag)
        let unicornCupIndex = GameSetup.assignUnicornCupIndex(cups: cups)

        return GameSession(
            phase: .setup,
            players: players,
            currentPlayerIndex: 0,
            cups: cups,
            gemsInBag: gemsInBag,
            unicornCupIndex: unicornCupIndex,
            unicornCupID: cups[unicornCupIndex].id
        )
    }
}
