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
    /// Gems the active player is holding during the current turn.
    var gemsInHand: [Gem]
    /// Gems placed in the discard pile this game. Magic on discard is not implemented yet.
    var discardPile: [Gem]
    /// D12 roll for the current turn, if a turn has started.
    var currentRoll: Int?
    /// Index into `cups` where the next gem should be placed (moves clockwise each placement).
    var nextPlacementCupIndex: Int
    /// Whether the unicorn is on the board and which cup holds it, if any.
    var unicornCupID: UUID?

    init(
        id: UUID = UUID(),
        phase: GamePhase = .setup,
        players: [Player] = [],
        currentPlayerIndex: Int = 0,
        cups: [Cup] = [],
        gemsInBag: [Gem] = [],
        gemsInHand: [Gem] = [],
        discardPile: [Gem] = [],
        currentRoll: Int? = nil,
        nextPlacementCupIndex: Int = 0,
        unicornCupID: UUID? = nil
    ) {
        self.id = id
        self.phase = phase
        self.players = players
        self.currentPlayerIndex = currentPlayerIndex
        self.cups = cups
        self.gemsInBag = gemsInBag
        self.gemsInHand = gemsInHand
        self.discardPile = discardPile
        self.currentRoll = currentRoll
        self.nextPlacementCupIndex = nextPlacementCupIndex
        self.unicornCupID = unicornCupID
    }
}
