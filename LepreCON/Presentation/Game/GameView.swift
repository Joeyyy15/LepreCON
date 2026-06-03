//
// GameView.swift
// LepreCON
//
// Game screen: displays board state and forwards user actions to the ViewModel.
// Game rules live in the Domain layer, not in this view.
//

import SwiftUI

@MainActor
struct GameView: View {
    @StateObject var viewModel: GameViewModel
    let onFinishGame: () -> Void

    @State private var lastActionMessage: String?
    @State private var showsScoringSheet = false
    @State private var showsResolutionSheet = false

    init(onFinishGame: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: GameViewModel())
        self.onFinishGame = onFinishGame
    }

    init(viewModel: GameViewModel, onFinishGame: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onFinishGame = onFinishGame
    }

    var body: some View {
        GeometryReader { geometry in
            let boardHeight = GameScreenLayout.boardHeight(in: geometry.size.height)

            ZStack {
                GameSceneBackgroundView()

                VStack(spacing: 0) {
                    topZone
                        .padding(.bottom, GameScreenLayout.hudToBoardGap)

                    boardZone
                        .frame(height: boardHeight)

                    bottomDock
                        .padding(.top, GameScreenLayout.boardToDockGap)
                }
                .padding(.horizontal, GameScreenLayout.horizontalPadding)
                .padding(.top, GameScreenLayout.topPadding)
                .padding(.bottom, GameScreenLayout.bottomPadding)
            }
        }
        .overlay(alignment: .top) {
            GameActionFeedbackView(message: lastActionMessage)
                .padding(.top, GameScreenLayout.topBarHeight + GameScreenLayout.topPadding + 4)
        }
        .sheet(isPresented: $showsScoringSheet) {
            GameScoringSheetView(
                rows: viewModel.boardDisplayState.pendingScoringCups,
                onConfirmScore: { cupIndex, color in
                    confirmScore(cupIndex: cupIndex, scoringColor: color)
                },
                onSkipScoring: {
                    skipScoring()
                    showsScoringSheet = false
                }
            )
        }
        .sheet(isPresented: $showsResolutionSheet) {
            resolutionSheet
        }
        .onChange(of: viewModel.boardDisplayState.pendingScoringCups) { _, cups in
            showsScoringSheet = !viewModel.isGameOver && !cups.isEmpty
        }
        .onChange(of: viewModel.resolutionEventPresentation) { _, presentation in
            showsResolutionSheet = presentation != nil
        }
        .overlay(alignment: .bottom) {
            gameOverBanner
        }
    }

    // MARK: - Screen zones

    private var topZone: some View {
        GameTopBarView(
            hud: viewModel.boardDisplayState.hud,
            canStartGame: viewModel.canStartGame,
            canEndGame: viewModel.canEndGame,
            showsGameControls: !viewModel.isGameOver,
            onStartGame: startGame,
            onEndGame: endGame
        )
        .frame(height: GameScreenLayout.topBarHeight)
        .zIndex(2)
    }

    private var boardZone: some View {
        GameBoardView(
            displayState: viewModel.boardDisplayState,
            onConfirmScore: confirmScore
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .zIndex(0)
    }

    private var bottomDock: some View {
        GameControlDockView(
            handGemCounts: viewModel.boardDisplayState.handGemCounts,
            currentRoll: viewModel.boardDisplayState.currentRoll,
            showsRollControl: !viewModel.isGameOver,
            canRollD12: viewModel.canRollD12,
            canPlaceFromHand: viewModel.canPlaceFromHand,
            showsUndo: !viewModel.isGameOver,
            canUndo: viewModel.canUndoLastPlacement,
            onRollD12: rollD12,
            onUndo: {
                viewModel.undoLastPlacement()
                lastActionMessage = "Last placement undone."
            },
            onTapHandGemKind: placeHandGemOfKind
        )
        .zIndex(1)
    }

    @ViewBuilder
    private var gameOverBanner: some View {
        if let gameOver = viewModel.boardDisplayState.gameOver {
            VStack(spacing: 8) {
                Text("Game Over — Score \(gameOver.finalScore.totalPoints)")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(BoardStyle.hudValue)

                Button("Play Again") {
                    viewModel.startNewGame()
                    lastActionMessage = "New game started. Roll D12 to begin your turn."
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(BoardStyle.hudPanelFill.opacity(0.95))
            )
            .padding(.bottom, GameScreenLayout.dockHeight + GameScreenLayout.bottomPadding + 8)
        }
    }

    private var resolutionSheet: some View {
        NavigationStack {
            Group {
                if let presentation = viewModel.resolutionEventPresentation {
                    TurnResolutionEventsPanel(
                        presentation: presentation,
                        highlightedLineIndex: viewModel.highlightedResolutionLineIndex
                    )
                    .padding()
                }
            }
            .navigationTitle("Turn Events")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        showsResolutionSheet = false
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    // MARK: - Menu actions (existing behavior)

    private func startGame() {
        viewModel.startGame()
        lastActionMessage = "Game started. Roll D12 to begin your turn."
    }

    private func endGame() {
        viewModel.endGame()
        onFinishGame()
    }

    // MARK: - Gameplay actions (unchanged behavior)

    private func rollD12() {
        switch viewModel.rollD12AndBeginTurn() {
        case .success:
            lastActionMessage = "Rolled \(viewModel.session.currentRoll ?? 0). Tap a hand gem to place."
        case .failure(let error):
            lastActionMessage = turnErrorMessage(error)
        }
    }

    private func placeHandGemOfKind(_ kind: GemKind) {
        switch viewModel.placeHandGem(kind: kind) {
        case .success:
            if viewModel.session.isTurnPlacementComplete {
                if viewModel.isInScoringChoicePhase {
                    lastActionMessage = "Placement finished. Score a cup or choose Skip Scoring."
                    showsScoringSheet = true
                } else {
                    lastActionMessage = "Placement finished. Roll D12 for your next turn."
                }
            } else {
                lastActionMessage = "Gem placed. Continue placing from your hand."
            }
        case .failure(let error):
            lastActionMessage = turnErrorMessage(error)
        }
    }

    private func confirmScore(cupIndex: Int, scoringColor: GemKind) {
        switch viewModel.confirmScore(cupIndex: cupIndex, scoringColor: scoringColor) {
        case .success:
            if viewModel.isInScoringChoicePhase {
                lastActionMessage = "Scored \(scoringColor.scoringDisplayName). Score another cup or choose Skip Scoring."
            } else {
                lastActionMessage = "Scored \(scoringColor.scoringDisplayName). Roll D12 when ready."
                showsScoringSheet = false
            }
        case .failure(let error):
            lastActionMessage = scoreConfirmationErrorMessage(error)
        }
    }

    private func skipScoring() {
        viewModel.skipScoringChoices()
        lastActionMessage = "Scoring skipped. Roll D12 when ready."
    }

    private func scoreConfirmationErrorMessage(_ error: ScoreConfirmationError) -> String {
        switch error {
        case .invalidCupIndex: return "Invalid cup."
        case .cupAlreadyCompleted: return "That cup is already scored."
        case .potOfGoldCannotScore: return "The Pot of Gold cannot be scored."
        case .noPendingScoreChoiceForCup: return "That cup has no pending score option."
        case .scoringCandidateNotAvailable: return "That scoring color is not available for this cup."
        case .potOfGoldMissing: return "Pot of Gold is missing from the board."
        }
    }

    private func turnErrorMessage(_ error: GameTurnError) -> String {
        switch error {
        case .gameNotPlaying: return "Start the game first."
        case .invalidRoll: return "Invalid roll."
        case .turnAlreadyInProgress: return "Finish the current turn before rolling again."
        case .noActiveTurn: return "Roll D12 and draw gems before placing."
        case .gemNotInHand: return "That gem is not in your hand."
        case .invalidPlacementCupIndex: return "Invalid cup for placement."
        case .pendingScoreChoicesUnresolved: return "Score a cup or choose Skip Scoring before rolling again."
        }
    }
}

#Preview {
    let viewModel = GameViewModel(playerNames: ["Player 1"])
    let _ = { viewModel.startGame() }()
    return GameView(viewModel: viewModel, onFinishGame: {})
}
