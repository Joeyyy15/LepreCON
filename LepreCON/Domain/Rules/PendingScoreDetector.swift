//
// PendingScoreDetector.swift
// LepreCON
//
// Finds scoreable cups after placement ends. Uses ScoreEvaluator — no duplicate scoring logic.
// Does not complete cups, move gold, or clear gems.
//

import Foundation

/// Detects pending scoring options on the current board state.
enum PendingScoreDetector {

    /// Scans every non-completed, non-pot cup and returns cups with at least one valid candidate.
    static func detectPendingChoices(in session: GameSession) -> [PendingScoreChoice] {
        session.cups.enumerated().compactMap { cupIndex, cup in
            guard !cup.isCompleted, !cup.isPotOfGold else { return nil }

            let result = ScoreEvaluator.evaluate(cup: cup)
            guard !result.candidates.isEmpty else { return nil }

            return PendingScoreChoice(cupIndex: cupIndex, candidates: result.candidates)
        }
    }

    /// Replaces pending choices with a fresh scan of the board (after placement ends).
    static func refreshPendingScoreChoices(in session: inout GameSession) {
        session.pendingScoreChoices = detectPendingChoices(in: session)
    }

    /// Clears stale choices when a new turn begins.
    static func clearPendingScoreChoices(in session: inout GameSession) {
        session.pendingScoreChoices = []
    }
}
