//
// EndOfTurnResolver.swift
// LepreCON
//
// Runs end-of-turn resolution in rulebook order after placement ends:
// Unicorn → Poop → Score detection.
//
// Unicorn and poop resolution are wired.
//

import Foundation

/// Ordered end-of-turn resolution steps after the player finishes placing gems.
enum EndOfTurnResolver {

    /// Runs every resolution step in rulebook order. Call when placement ends.
    static func resolveAfterPlacementEnds(session: inout GameSession) {
        session.recentResolutionEvents.removeAll()
        resolveUnicorn(in: &session)
        resolvePoop(in: &session)
        refreshPendingScores(in: &session)
    }

    // MARK: - Resolution steps (rulebook order)

    private static func resolveUnicorn(in session: inout GameSession) {
        UnicornResolver.resolve(in: &session)
    }

    private static func resolvePoop(in session: inout GameSession) {
        PoopResolver.resolve(in: &session)
    }

    /// Refreshes pending score choices from the current board. Player confirms scoring later.
    private static func refreshPendingScores(in session: inout GameSession) {
        PendingScoreDetector.refreshPendingScoreChoices(in: &session)
    }
}
