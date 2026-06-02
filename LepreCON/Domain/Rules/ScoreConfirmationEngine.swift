//
// ScoreConfirmationEngine.swift
// LepreCON
//
// Applies a player-chosen pending score to a cup. Does not auto-pick a color.
// Moves gold to the Pot of Gold and clears remaining gems from the scored cup.
//

import Foundation

/// Errors that can occur when the player confirms a pending score.
enum ScoreConfirmationError: Error, Equatable {
    case invalidCupIndex
    case cupAlreadyCompleted
    case potOfGoldCannotScore
    case noPendingScoreChoiceForCup
    case scoringCandidateNotAvailable
    case potOfGoldMissing
}

/// Confirms one pending scoring option chosen by the player.
enum ScoreConfirmationEngine {

    /// Marks a cup as scored for the chosen rainbow color.
    static func confirmScore(
        session: inout GameSession,
        cupIndex: Int,
        scoringColor: GemKind
    ) -> Result<Void, ScoreConfirmationError> {
        guard session.cups.indices.contains(cupIndex) else {
            return .failure(.invalidCupIndex)
        }

        let cup = session.cups[cupIndex]

        guard !cup.isCompleted else {
            return .failure(.cupAlreadyCompleted)
        }

        guard !cup.isPotOfGold else {
            return .failure(.potOfGoldCannotScore)
        }

        guard let pendingChoice = session.pendingScoreChoices.first(where: { $0.cupIndex == cupIndex }) else {
            return .failure(.noPendingScoreChoiceForCup)
        }

        guard let candidate = pendingChoice.candidates.first(where: { $0.scoringColor == scoringColor }) else {
            return .failure(.scoringCandidateNotAvailable)
        }

        session.cups[cupIndex].completion = CupCompletion(from: candidate)

        let moveGoldResult = moveGoldToPotOfGold(session: &session, fromCupIndex: cupIndex)
        if case .failure(let error) = moveGoldResult {
            return .failure(error)
        }

        session.cups[cupIndex].gems.removeAll()

        PendingScoreDetector.refreshPendingScoreChoices(in: &session)

        return .success(())
    }

    // MARK: - Helpers

    private static func moveGoldToPotOfGold(
        session: inout GameSession,
        fromCupIndex cupIndex: Int
    ) -> Result<Void, ScoreConfirmationError> {
        guard let potIndex = session.cups.firstIndex(where: { $0.isPotOfGold }) else {
            return .failure(.potOfGoldMissing)
        }

        let goldGems = session.cups[cupIndex].gems.filter { $0.kind == .gold }
        session.cups[potIndex].gems.append(contentsOf: goldGems)
        session.cups[cupIndex].gems.removeAll { $0.kind == .gold }

        return .success(())
    }
}
