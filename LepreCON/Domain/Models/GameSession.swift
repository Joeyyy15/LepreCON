//
// GameSession.swift
// LepreCON
//
// Represents the current state of one game: who is playing, the cups on the board,
// gems still in the bag, and which phase the game is in. Not connected to UI yet.
//

import Foundation

/// High-level phase of a game session.
enum GamePhase: String, Codable {
    case setup
    case playing
    case finished
}

/// The full state of a single game in progress (or recently finished).
struct GameSession: Identifiable, Equatable, Codable {
    let id: UUID
    var phase: GamePhase
    var players: [Player]
    /// Index into `players` for whose turn it is (when playing).
    var currentPlayerIndex: Int
    /// Cups arranged around the board (including Pot of Gold when applicable).
    var cups: [Cup]
    /// Gems still available to draw from the bag.
    var gemsInBag: [Gem]
    /// Whether the unicorn is on the board and which cup holds it, if any.
    var unicornCupID: UUID?

    init(
        id: UUID = UUID(),
        phase: GamePhase = .setup,
        players: [Player] = [],
        currentPlayerIndex: Int = 0,
        cups: [Cup] = [],
        gemsInBag: [Gem] = [],
        unicornCupID: UUID? = nil
    ) {
        self.id = id
        self.phase = phase
        self.players = players
        self.currentPlayerIndex = currentPlayerIndex
        self.cups = cups
        self.gemsInBag = gemsInBag
        self.unicornCupID = unicornCupID
    }
}
