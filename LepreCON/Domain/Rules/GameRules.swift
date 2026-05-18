//
// GameRules.swift
// LepreCON
//
// Central place for LepreCON board game rules. The app supports one game mode for now,
// so this uses simple static helpers instead of a Strategy Pattern.
//
// If you later add multiple game modes or scoring systems, this file can evolve into
// a protocol (e.g. GameRulesProtocol) with one implementation per mode.
//

import Foundation

/// Rule checks and helpers for the standard LepreCON game mode.
enum GameRules {

    /// Returns whether the session has enough setup to begin play.
    /// Placeholder: requires at least one player and the game must still be in setup.
    static func canStartGame(_ session: GameSession) -> Bool {
        guard session.phase == .setup else { return false }
        guard !session.players.isEmpty else { return false }
        // Placeholder: add cup layout, bag contents, etc. when setup rules are implemented.
        return true
    }

    /// Returns whether the game has ended.
    /// Placeholder: true when the session phase is finished.
    static func isGameOver(_ session: GameSession) -> Bool {
        session.phase == .finished
    }

    /// Returns the player whose turn it is, if the session is in play and the index is valid.
    static func currentPlayer(in session: GameSession) -> Player? {
        guard session.phase == .playing else { return nil }
        guard session.players.indices.contains(session.currentPlayerIndex) else { return nil }
        return session.players[session.currentPlayerIndex]
    }
}
