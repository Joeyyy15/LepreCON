//
// WhiteGemDecisionEngine.swift
// LepreCON
//
// Applies a player-chosen white-gem decision for one pending context at a time.
//

import Foundation

/// Errors that can occur when resolving a pending white-gem decision.
enum WhiteGemDecisionError: Error, Equatable {
    case gameNotPlaying
    case noPendingDecision
    case invalidCupIndex
    case unexpectedDecisionKind
    case whiteGemNotInCup
}

/// Confirms the player's choice for the currently pending white-gem context.
enum WhiteGemDecisionEngine {

    /// Resolves a placement-chain pause: scoop-and-continue, or discard one white and end the turn.
    static func resolvePlacementChain(
        session: inout GameSession,
        scoopAndContinue: Bool
    ) -> Result<Void, WhiteGemDecisionError> {
        guard session.phase == .playing else { return .failure(.gameNotPlaying) }
        guard case .endPlacementChain(let cupIndex) = session.pendingWhiteGemDecision else {
            return session.pendingWhiteGemDecision == nil
                ? .failure(.noPendingDecision)
                : .failure(.unexpectedDecisionKind)
        }
        guard session.cups.indices.contains(cupIndex) else {
            return .failure(.invalidCupIndex)
        }

        session.pendingWhiteGemDecision = nil

        if scoopAndContinue {
            resumePlacementByScooping(session: &session, cupIndex: cupIndex)
            return .success(())
        }

        guard discardOneWhiteGem(fromCupIndex: cupIndex, in: &session) else {
            return .failure(.whiteGemNotInCup)
        }
        finishPlacementPhase(session: &session)
        return .success(())
    }

    /// Resolves an end-of-turn unicorn pause: explode/spread, or discard one white and calm.
    static func resolveUnicornSpread(
        session: inout GameSession,
        explode: Bool
    ) -> Result<Void, WhiteGemDecisionError> {
        guard session.phase == .playing else { return .failure(.gameNotPlaying) }
        guard case .stopUnicornSpread(let cupIndex) = session.pendingWhiteGemDecision else {
            return session.pendingWhiteGemDecision == nil
                ? .failure(.noPendingDecision)
                : .failure(.unexpectedDecisionKind)
        }
        guard session.cups.indices.contains(cupIndex) else {
            return .failure(.invalidCupIndex)
        }

        session.pendingWhiteGemDecision = nil

        if explode {
            _ = UnicornResolver.explode(in: &session)
        } else {
            _ = UnicornResolver.calm(in: &session)
        }
        EndOfTurnResolver.resolveRemainingAfterUnicorn(session: &session)
        return .success(())
    }

    // MARK: - Helpers

    /// True when a cup currently holds at least one white gem.
    static func cupContainsWhiteGem(_ cup: Cup) -> Bool {
        cup.gems.contains { $0.kind == .white }
    }

    /// Moves exactly one white gem from the cup into the discard pile.
    @discardableResult
    static func discardOneWhiteGem(fromCupIndex cupIndex: Int, in session: inout GameSession) -> Bool {
        guard session.cups.indices.contains(cupIndex),
              let whiteIndex = session.cups[cupIndex].gems.firstIndex(where: { $0.kind == .white })
        else {
            return false
        }
        let whiteGem = session.cups[cupIndex].gems.remove(at: whiteIndex)
        session.discardPile.append(whiteGem)
        return true
    }

    /// Scoops the landing cup and continues the placement chain.
    private static func resumePlacementByScooping(session: inout GameSession, cupIndex: Int) {
        session.isTurnPlacementComplete = false
        GameTurnEngine.scoopCupIntoHand(session: &session, cupIndex: cupIndex)
        session.nextPlacementCupIndex = cupIndex
        GameTurnEngine.advancePlacementIndex(session: &session)
    }

    /// Ends placement and starts normal end-of-turn resolution (Unicorn → Poop → scores).
    private static func finishPlacementPhase(session: inout GameSession) {
        session.isTurnPlacementComplete = true
        EndOfTurnResolver.resolveAfterPlacementEnds(session: &session)
    }
}
