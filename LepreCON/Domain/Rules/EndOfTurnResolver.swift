//
// EndOfTurnResolver.swift
// LepreCON
//
// Runs end-of-turn resolution in rulebook order after placement ends:
// Unicorn → Poop → Score detection.
//
// A white gem in the unicorn cup pauses here for a pending player decision
// instead of auto-calming.
//

import Foundation

/// Ordered end-of-turn resolution steps after the player finishes placing gems.
enum EndOfTurnResolver {

    /// Runs every resolution step in rulebook order. Call when placement ends.
    /// If the unicorn cup contains a white gem, records a pending decision and returns
    /// without poop or score detection.
    static func resolveAfterPlacementEnds(session: inout GameSession) {
        session.recentResolutionEvents.removeAll()

        if UnicornResolver.requiresPlayerDecision(in: session),
           let unicornIndex = session.unicornCupIndex {
            session.pendingWhiteGemDecision = .stopUnicornSpread(cupIndex: unicornIndex)
            return
        }

        resolveUnicorn(in: &session)
        resolveRemainingAfterUnicorn(session: &session)
    }

    /// Poop then score detection. Used after the player resolves a white-gem unicorn choice.
    static func resolveRemainingAfterUnicorn(session: inout GameSession) {
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
