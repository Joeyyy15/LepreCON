//
// EndOfTurnResolver.swift
// LepreCON
//
// Runs end-of-turn resolution in rulebook order after placement ends:
// Unicorn → Poop → Score detection.
//
// Only score detection is wired today. Unicorn and poop are intentional stubs.
//

import Foundation

/// Ordered end-of-turn resolution steps after the player finishes placing gems.
enum EndOfTurnResolver {

    /// Runs every resolution step in rulebook order. Call when placement ends.
    static func resolveAfterPlacementEnds(session: inout GameSession) {
        resolveUnicorn(in: &session)
        resolvePoop(in: &session)
        refreshPendingScores(in: &session)
    }

    // MARK: - Resolution steps (rulebook order)

    private static func resolveUnicorn(in session: inout GameSession) {
        // TODO: Implement unicorn resolution later (runs before poop and scoring).
        _ = session
    }

    private static func resolvePoop(in session: inout GameSession) {
        // TODO: Implement black gem / poop resolution later (runs before scoring).
        _ = session
    }

    /// Refreshes pending score choices from the current board. Player confirms scoring later.
    private static func refreshPendingScores(in session: inout GameSession) {
        PendingScoreDetector.refreshPendingScoreChoices(in: &session)
    }
}
