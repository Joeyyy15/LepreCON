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

    init(onFinishGame: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: GameViewModel())
        self.onFinishGame = onFinishGame
    }

    init(viewModel: GameViewModel, onFinishGame: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onFinishGame = onFinishGame
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                GameHUDView(hud: viewModel.boardDisplayState.hud)

                GameBoardView(
                    displayState: viewModel.boardDisplayState,
                    onConfirmScore: confirmScore
                )
                .frame(maxWidth: .infinity)
                .frame(height: 360)

                if !viewModel.isGameOver,
                   !viewModel.boardDisplayState.pendingScoringCups.isEmpty {
                    CupScoringControlsSection(
                        rows: viewModel.boardDisplayState.pendingScoringCups,
                        onConfirmScore: confirmScore,
                        onSkipScoring: skipScoring
                    )
                }

                if let presentation = viewModel.resolutionEventPresentation {
                    TurnResolutionEventsPanel(
                        presentation: presentation,
                        highlightedLineIndex: viewModel.highlightedResolutionLineIndex
                    )
                }

                GameStatusMessageView(
                    playerName: viewModel.currentPlayerName,
                    placementGuidance: placementGuidanceText,
                    unicornStatusLine: viewModel.boardDisplayState.unicornStatus.statusLine,
                    unicornIsCaptured: viewModel.boardDisplayState.unicornStatus.isCaptured,
                    gameOver: viewModel.boardDisplayState.gameOver,
                    showRainbowCompleteMessage: viewModel.isRainbowComplete && viewModel.boardDisplayState.gameOver == nil,
                    onPlayAgain: {
                        viewModel.startNewGame()
                        lastActionMessage = "New game started. Roll D12 to begin your turn."
                    }
                )

                GameActionAreaView(
                    showsRollButton: !viewModel.isGameOver,
                    canRollD12: viewModel.canRollD12,
                    onRollD12: rollD12
                )

                HandPanelView(
                    handGemCounts: viewModel.boardDisplayState.handGemCounts,
                    emptyHandMessage: viewModel.canRollD12 ? "Roll D12 to draw gems" : "No gems in hand",
                    canPlaceFromHand: viewModel.canPlaceFromHand,
                    showsUndo: !viewModel.isGameOver,
                    canUndoLastPlacement: viewModel.canUndoLastPlacement,
                    onTapHandGemKind: placeHandGemOfKind,
                    onUndoLastPlacement: {
                        viewModel.undoLastPlacement()
                        lastActionMessage = "Last placement undone."
                    }
                )

                DiscardPileView(gemCounts: viewModel.boardDisplayState.discardGemCounts)

                GameFooterControlsView(
                    showsControls: !viewModel.isGameOver,
                    canStartGame: viewModel.canStartGame,
                    canEndGame: viewModel.canEndGame,
                    onStartGame: {
                        viewModel.startGame()
                        lastActionMessage = "Game started. Roll D12 to begin your turn."
                    },
                    onEndGame: {
                        viewModel.endGame()
                        onFinishGame()
                    }
                )

                GameActionFeedbackView(message: lastActionMessage)
            }
            .padding()
        }
    }

    private var placementGuidanceText: String? {
        guard !viewModel.isGameOver,
              viewModel.boardDisplayState.isTurnPlacementComplete else {
            return nil
        }
        if viewModel.isInScoringChoicePhase {
            return "Score a cup below or choose Skip Scoring to continue."
        }
        return "Placement complete — roll D12 for your next turn."
    }

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
