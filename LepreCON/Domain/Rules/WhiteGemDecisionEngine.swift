//
// WhiteGemDecisionEngine.swift
// LepreCON
//
// Applies a player-chosen white-gem / unicorn decision. Does not auto-pick.
//

import Foundation

/// Errors that can occur when resolving a pending white-gem decision.
enum WhiteGemDecisionError: Error, Equatable {
    case gameNotPlaying
    case noPendingDecision
    case invalidCupIndex
}

/// Confirms the player's unicorn and cup/chain choices for a pending white gem.
enum WhiteGemDecisionEngine {

    /// Applies both outcomes of a pending white-gem decision.
    ///
    /// Unicorn: `triggerUnicorn` explodes using the existing clockwise spread;
    /// `false` calms only when the turn is ending (discards one white, unicorn stays).
    /// Chain: `scoopAndContinue` picks up every remaining gem in the affected cup
    /// (including white) and resumes placement; `false` leaves the cup and ends the turn.
    static func resolve(
        session: inout GameSession,
        triggerUnicorn: Bool,
        scoopAndContinue: Bool
    ) -> Result<Void, WhiteGemDecisionError> {
        guard session.phase == .playing else { return .failure(.gameNotPlaying) }
        guard let pending = session.pendingWhiteGemDecision else {
            return .failure(.noPendingDecision)
        }
        guard session.cups.indices.contains(pending.cupIndex) else {
            return .failure(.invalidCupIndex)
        }

        session.pendingWhiteGemDecision = nil
        session.recentResolutionEvents.removeAll()

        if scoopAndContinue {
            if triggerUnicorn {
                _ = UnicornResolver.explode(in: &session)
            }
            resumePlacementByScooping(session: &session, cupIndex: pending.cupIndex)
        } else {
            if triggerUnicorn {
                _ = UnicornResolver.explode(in: &session)
            } else {
                _ = UnicornResolver.calm(in: &session)
            }
            finishTurnAfterUnicornChoice(session: &session)
        }

        return .success(())
    }

    // MARK: - Helpers

    /// Scoops the affected cup and continues the placement chain without ending the turn.
    private static func resumePlacementByScooping(session: inout GameSession, cupIndex: Int) {
        session.isTurnPlacementComplete = false
        GameTurnEngine.scoopCupIntoHand(session: &session, cupIndex: cupIndex)
        session.nextPlacementCupIndex = cupIndex
        GameTurnEngine.advancePlacementIndex(session: &session)

        if session.gemsInHand.isEmpty {
            finishTurnAfterUnicornChoice(session: &session)
        }
    }

    /// Ends placement and runs remaining end-of-turn steps (poop, then score detection).
    /// Unicorn was already applied by the player's choice.
    private static func finishTurnAfterUnicornChoice(session: inout GameSession) {
        session.isTurnPlacementComplete = true
        EndOfTurnResolver.resolveRemainingAfterUnicorn(session: &session)
    }
}
