//
// GameViewModel.swift
// LepreCON
//
// Owns the current game session and coordinates domain logic for the game screen.
// SwiftUI views read from here; they do not create GameSession values directly.
//

import Foundation
import Combine

@MainActor
final class GameViewModel: ObservableObject {

    /// The active game state (players, cups, bag, phase). Updated as the game progresses.
    @Published private(set) var session: GameSession

    private let factory: GameSessionFactory

    /// Session state saved immediately before the most recent successful placement (one-step undo).
    private var previousSessionSnapshot: GameSession?

    /// Presentation adapter for the board and controls. Recomputed when session changes.
    var boardDisplayState: GameBoardDisplayState {
        GameBoardDisplayState.from(session: session)
    }

    /// Display name for whoever's turn it is, when the game is in the playing phase.
    var currentPlayerName: String? {
        GameRules.currentPlayer(in: session)?.name
    }

    var phaseDisplayText: String {
        session.phase.rawValue.capitalized
    }

    var canEndGame: Bool {
        GameRules.canEndGame(session)
    }

    var canStartGame: Bool {
        GameRules.canStartGame(session)
    }

    var canRollD12: Bool {
        GameTurnEngine.canRollD12(in: session)
    }

    var canPlaceFromHand: Bool {
        boardDisplayState.canPlaceFromHand
    }

    /// True when the player can undo exactly one prior successful gem placement.
    var canUndoLastPlacement: Bool {
        previousSessionSnapshot != nil && session.phase == .playing && !isGameOver
    }

    var hasPendingScoreChoices: Bool {
        !session.pendingScoreChoices.isEmpty
    }

    /// Current final score breakdown from completed cups and the Pot of Gold.
    var finalScoreResult: FinalScoreResult {
        FinalScoreEvaluator.evaluate(session: session)
    }

    var gameCompletionStatus: GameCompletionStatus {
        GameCompletionDetector.status(for: session)
    }

    var isGameOver: Bool {
        gameCompletionStatus.isGameOver
    }

    var isRainbowComplete: Bool {
        gameCompletionStatus.isRainbowComplete
    }

    var didWin: Bool {
        gameCompletionStatus.didWin
    }

    /// True after placement when the player must score or skip before rolling again.
    var isInScoringChoicePhase: Bool {
        session.isTurnPlacementComplete && hasPendingScoreChoices
    }

    var canSkipScoring: Bool {
        isInScoringChoicePhase && !isGameOver
    }

    /// Clears pending score choices so the player can roll again without confirming a score.
    func skipScoringChoices() {
        clearUndoSnapshot()
        PendingScoreDetector.clearPendingScoreChoices(in: &session)
        applyGameOverIfNeeded()
    }

    /// Pending scoring options for one cup, mapped for the UI.
    func pendingScoreChoicesForCup(cupIndex: Int) -> [PendingScoreOptionDisplay] {
        GameBoardDisplayState.scoringDisplay(forCupIndex: cupIndex, session: session).pendingOptions
    }

    /// Restores the session to immediately before the last successful placement.
    func undoLastPlacement() {
        guard let snapshot = previousSessionSnapshot else { return }
        session = snapshot
        clearUndoSnapshot()
    }

    /// Player confirms one pending scoring color for a cup.
    func confirmScore(cupIndex: Int, scoringColor: GemKind) -> Result<Void, ScoreConfirmationError> {
        clearUndoSnapshot()
        let result = ScoreConfirmationEngine.confirmScore(
            session: &session,
            cupIndex: cupIndex,
            scoringColor: scoringColor
        )
        if case .success = result {
            applyGameOverIfNeeded()
        }
        return result
    }

    init(
        factory: GameSessionFactory = GameSessionFactory(),
        playerNames: [String] = ["Player 1"],
        session: GameSession? = nil
    ) {
        self.factory = factory
        self.session = session ?? factory.makeNewGame(playerNames: playerNames)
    }

    func startGame() {
        guard GameRules.canStartGame(session) else { return }
        session.phase = .playing
    }

    /// Replaces the session with a fresh game (same player names) and starts play.
    func startNewGame() {
        clearUndoSnapshot()
        let playerNames = session.players.map(\.name)
        session = factory.makeNewGame(
            playerNames: playerNames.isEmpty ? ["Player 1"] : playerNames
        )
        session.phase = .playing
    }

    func endGame() {
        guard GameRules.canEndGame(session) else { return }
        clearUndoSnapshot()
        session.phase = .finished
    }

    /// Rolls D12 (1–12) and begins a turn via the domain engine.
    func rollD12AndBeginTurn() -> Result<Void, GameTurnError> {
        let roll = Int.random(in: 1...12)
        return beginTurn(roll: roll)
    }

    func beginTurn(roll: Int) -> Result<Void, GameTurnError> {
        let result = GameTurnEngine.beginTurn(session: &session, roll: roll)
        if case .success = result {
            clearUndoSnapshot()
        }
        return result
    }

    /// Places the chosen hand gem into the currently highlighted cup on the board path.
    func placeGemInCurrentCup(gemID: UUID) -> Result<Void, GameTurnError> {
        let snapshotBeforePlacement = session
        let result = GameTurnEngine.placeGemInCurrentCup(session: &session, gemID: gemID)
        switch result {
        case .success:
            previousSessionSnapshot = snapshotBeforePlacement
            applyGameOverIfNeeded()
        case .failure:
            break
        }
        return result
    }

    private func clearUndoSnapshot() {
        previousSessionSnapshot = nil
    }

    private func applyGameOverIfNeeded() {
        GameCompletionDetector.applyGameOverIfNeeded(to: &session)
        if isGameOver {
            clearUndoSnapshot()
        }
    }
}
