//
// GameCompletionDetector.swift
// LepreCON
//
// Detects when the game is over vs when the player won (rainbow complete).
// Scoring math stays in FinalScoreEvaluator.
//

import Foundation

/// Game-over and win state derived from the session.
struct GameCompletionStatus: Equatable {
    let isGameOver: Bool
    let isRainbowComplete: Bool
    let didWin: Bool
}

/// Checks game-over and win conditions for LepreCON.
enum GameCompletionDetector {

    /// Full completion status. When `phase` is `.finished`, `isGameOver` is always true.
    static func status(for session: GameSession) -> GameCompletionStatus {
        let rainbowComplete = isRainbowComplete(session: session)
        let gameOver = session.phase == .finished || shouldEnterGameOver(session: session)
        return GameCompletionStatus(
            isGameOver: gameOver,
            isRainbowComplete: rainbowComplete,
            didWin: gameOver && rainbowComplete
        )
    }

    /// True when every rainbow color has been scored at least once.
    static func isRainbowComplete(session: GameSession) -> Bool {
        FinalScoreEvaluator.evaluate(session: session).isRainbowComplete
    }

    /// True when the session should be in the game-over / results state.
    static func isGameOver(session: GameSession) -> Bool {
        session.phase == .finished || shouldEnterGameOver(session: session)
    }

    /// True when the game is over and the player collected all six rainbow colors.
    static func didWin(session: GameSession) -> Bool {
        isGameOver(session: session) && isRainbowComplete(session: session)
    }

    /// Moves the session to `.finished` when a game-over condition is met.
    static func applyGameOverIfNeeded(to session: inout GameSession) {
        guard session.phase == .playing else { return }
        guard shouldEnterGameOver(session: session) else { return }
        session.phase = .finished
    }

    /// Number of scoreable (non-pot) cups on the board.
    static var scoreableCupCount: Int { GameSetup.boardSlotLayout.count - 1 }

    /// How many non-pot cups are currently completed.
    static func completedScoreableCupCount(in session: GameSession) -> Int {
        session.cups.filter { !$0.isPotOfGold && $0.isCompleted }.count
    }

    // MARK: - Game-over conditions

    private static func shouldEnterGameOver(session: GameSession) -> Bool {
        guard session.phase == .playing else { return false }
        return allNonPotCupsCompleted(session: session)
            || isBagEmptyAfterFinalTurnResolved(session: session)
    }

    /// Every cup except the Pot of Gold has been scored.
    private static func allNonPotCupsCompleted(session: GameSession) -> Bool {
        session.cups.allSatisfy { $0.isPotOfGold || $0.isCompleted }
    }

    /// Bag is empty and the last turn fully resolved (placed, end-of-turn, scoring cleared).
    private static func isBagEmptyAfterFinalTurnResolved(session: GameSession) -> Bool {
        guard session.gemsInBag.isEmpty else { return false }
        guard session.gemsInHand.isEmpty else { return false }
        guard session.isTurnPlacementComplete else { return false }
        guard !GameTurnEngine.isTurnInProgress(in: session) else { return false }
        guard session.pendingScoreChoices.isEmpty else { return false }
        return true
    }
}
