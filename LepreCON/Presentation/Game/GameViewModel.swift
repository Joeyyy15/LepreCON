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

    /// Temporary UI for the latest end-of-turn unicorn/poop events (no domain delay).
    @Published private(set) var resolutionEventPresentation: TurnResolutionEventPresentation?
    @Published private(set) var highlightedResolutionLineIndex: Int?

    /// Read-only script for replaying unicorn resolution on the board overlay.
    @Published private(set) var unicornAnimationScript: UnicornAnimationScript?
    @Published private(set) var isUnicornAnimationPlaying = false

    private let factory: GameSessionFactory
    private var resolutionHighlightTask: Task<Void, Never>?

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
        refreshResolutionEventPresentation()
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
        clearResolutionEventPresentation()
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
            clearResolutionEventPresentation()
        }
        return result
    }

    /// Places one gem of the given kind from hand (first matching instance).
    func placeHandGem(kind: GemKind) -> Result<Void, GameTurnError> {
        guard let gem = session.gemsInHand.first(where: { $0.kind == kind }) else {
            return .failure(.gemNotInHand)
        }
        return placeGemInCurrentCup(gemID: gem.id)
    }

    /// Places the chosen hand gem into the currently highlighted cup on the board path.
    func placeGemInCurrentCup(gemID: UUID) -> Result<Void, GameTurnError> {
        let snapshotBeforePlacement = session
        let result = GameTurnEngine.placeGemInCurrentCup(session: &session, gemID: gemID)
        switch result {
        case .success:
            previousSessionSnapshot = snapshotBeforePlacement
            applyGameOverIfNeeded()
            refreshResolutionEventPresentation()
        case .failure:
            break
        }
        return result
    }

    func finishUnicornAnimation() {
        unicornAnimationScript = nil
        isUnicornAnimationPlaying = false
    }

    private func refreshResolutionEventPresentation() {
        resolutionHighlightTask?.cancel()
        resolutionEventPresentation = TurnResolutionEventDisplayBuilder.presentation(
            events: session.recentResolutionEvents,
            cups: session.cups
        )
        if let script = UnicornResolutionAnimationBuilder.script(
            from: session.recentResolutionEvents
        ) {
            unicornAnimationScript = script
            isUnicornAnimationPlaying = true
        } else {
            finishUnicornAnimation()
        }
        guard let presentation = resolutionEventPresentation, !presentation.logLines.isEmpty else {
            highlightedResolutionLineIndex = nil
            return
        }
        highlightedResolutionLineIndex = 0
        resolutionHighlightTask = Task { [weak self] in
            for index in presentation.logLines.indices {
                guard !Task.isCancelled else { return }
                await MainActor.run {
                    self?.highlightedResolutionLineIndex = index
                }
                try? await Task.sleep(nanoseconds: 550_000_000)
            }
        }
    }

    private func clearResolutionEventPresentation() {
        resolutionHighlightTask?.cancel()
        resolutionHighlightTask = nil
        resolutionEventPresentation = nil
        highlightedResolutionLineIndex = nil
        finishUnicornAnimation()
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
