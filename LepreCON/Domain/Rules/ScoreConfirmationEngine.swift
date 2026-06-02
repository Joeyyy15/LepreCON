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

        guard let potIndex = potOfGoldIndex(in: session) else {
            return .failure(.potOfGoldMissing)
        }

        applyConfirmedScore(
            session: &session,
            cupIndex: cupIndex,
            potIndex: potIndex,
            candidate: candidate
        )

        PendingScoreDetector.refreshPendingScoreChoices(in: &session)

        return .success(())
    }

    // MARK: - Helpers

    private static func potOfGoldIndex(in session: GameSession) -> Int? {
        session.cups.firstIndex(where: { $0.isPotOfGold })
    }

    /// Applies score mutations after all validation passes. Pot index is guaranteed valid.
    private static func applyConfirmedScore(
        session: inout GameSession,
        cupIndex: Int,
        potIndex: Int,
        candidate: CupScoreCandidate
    ) {
        let goldGems = session.cups[cupIndex].gems.filter { $0.kind == .gold }
        session.cups[potIndex].gems.append(contentsOf: goldGems)
        session.cups[cupIndex].gems.removeAll()
        session.cups[cupIndex].completion = CupCompletion(from: candidate)
    }
}
