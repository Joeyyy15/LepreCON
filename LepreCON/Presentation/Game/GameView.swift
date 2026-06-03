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
            VStack(spacing: 20) {
                GameBoardView(
                    displayState: viewModel.boardDisplayState,
                    onConfirmScore: confirmScore
                )
                    .frame(maxWidth: .infinity)
                    .frame(height: 380)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .shadow(color: .black.opacity(0.18), radius: 10, x: 0, y: 6)

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

                statusSection

                if !viewModel.isGameOver {
                    turnControlsSection
                }
                handSection
                discardSection
                gameControlsSection

                if let lastActionMessage {
                    Text(lastActionMessage)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            .padding()
        }
    }

    private var statusSection: some View {
        VStack(spacing: 8) {
            Text("Game Phase: \(viewModel.phaseDisplayText)")
                .font(.headline)

            Text("Current Player: \(viewModel.currentPlayerName ?? "Not started")")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            if let roll = viewModel.boardDisplayState.currentRoll {
                Text("D12 Roll: \(roll)")
                    .font(.subheadline.weight(.semibold))
            }

            if !viewModel.isGameOver,
               viewModel.boardDisplayState.isTurnPlacementComplete {
                if viewModel.isInScoringChoicePhase {
                    Text("Score a cup below or choose Skip Scoring to continue.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Text("Placement complete — roll again to start next turn")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Text(viewModel.boardDisplayState.unicornStatus.statusLine)
                .font(.subheadline)
                .foregroundStyle(
                    viewModel.boardDisplayState.unicornStatus.isCaptured ? .green : .secondary
                )

            if let gameOver = viewModel.boardDisplayState.gameOver {
                gameOverResultsSection(gameOver)
            } else {
                Text(viewModel.boardDisplayState.finalScore.summaryLine)
                    .font(.subheadline.weight(.semibold))

                if viewModel.isRainbowComplete {
                    Text("Rainbow complete — keep playing until the game ends.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private func gameOverResultsSection(_ gameOver: GameOverDisplay) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Game Over")
                .font(.headline)

            Text("Final Score: \(gameOver.finalScore.totalPoints)")
                .font(.subheadline.weight(.semibold))

            if let rank = gameOver.finalScore.rankDisplayName {
                Text("Rank: \(rank)")
                    .font(.subheadline)
            }

            Text("Rainbow Complete: \(gameOver.isRainbowComplete ? "Yes" : "No")")
                .font(.subheadline)

            Text(gameOver.unicornStatus.gameOverDetailLine)
                .font(.subheadline)
                .foregroundStyle(gameOver.unicornStatus.isCaptured ? .green : .secondary)

            if gameOver.didWin {
                Text("You collected the full rainbow!")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else if !gameOver.finalScore.missingColorNames.isEmpty {
                Text("Missing: \(gameOver.finalScore.missingColorNames.joined(separator: ", "))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text("Color: \(gameOver.finalScore.colorPoints) · Gold: \(gameOver.finalScore.goldPoints) · Unicorn: \(gameOver.finalScore.unicornPoints)")
                .font(.caption)
                .foregroundStyle(.secondary)

            Text("Completed cups: \(gameOver.completedCupCount)/\(gameOver.requiredCupCount)")
                .font(.caption)
                .foregroundStyle(.secondary)

            Button("Play Again") {
                viewModel.startNewGame()
                lastActionMessage = "New game started. Roll D12 to begin your turn."
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var turnControlsSection: some View {
        Button("Roll D12") {
            switch viewModel.rollD12AndBeginTurn() {
            case .success:
                lastActionMessage = "Rolled \(viewModel.session.currentRoll ?? 0). Tap a hand gem to place."
            case .failure(let error):
                lastActionMessage = turnErrorMessage(error)
            }
        }
        .buttonStyle(.borderedProminent)
        .disabled(!viewModel.canRollD12)
    }

    private var handSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Your Hand")
                .font(.headline)

            if viewModel.boardDisplayState.handGemCounts.isEmpty {
                Text(viewModel.canRollD12 ? "Roll D12 to draw gems" : "No gems in hand")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                HandGemsView(
                    gemCounts: viewModel.boardDisplayState.handGemCounts,
                    canPlace: viewModel.canPlaceFromHand,
                    onTapKind: placeHandGemOfKind
                )
            }

            if viewModel.canPlaceFromHand {
                Text("Tap a gem type to place one into the highlighted cup")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if !viewModel.isGameOver {
                Button("Undo Last Placement") {
                    viewModel.undoLastPlacement()
                    lastActionMessage = "Last placement undone."
                }
                .buttonStyle(.bordered)
                .disabled(!viewModel.canUndoLastPlacement)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var discardSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Discard Pile")
                .font(.headline)

            if viewModel.boardDisplayState.discardGemCounts.isEmpty {
                Text("Empty")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                LazyVGrid(
                    columns: [GridItem(.adaptive(minimum: 72, maximum: 120), spacing: 8)],
                    alignment: .leading,
                    spacing: 8
                ) {
                    ForEach(viewModel.boardDisplayState.discardGemCounts) { item in
                        GemCountBadgeView(item: item, style: .compact(gemSize: 28))
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var gameControlsSection: some View {
        HStack(spacing: 12) {
            if !viewModel.isGameOver {
                Button("Start Game") {
                    viewModel.startGame()
                    lastActionMessage = "Game started. Roll D12 to begin your turn."
                }
                .buttonStyle(.borderedProminent)
                .disabled(!viewModel.canStartGame)

                Button("End Game") {
                    viewModel.endGame()
                    onFinishGame()
                }
                .buttonStyle(.bordered)
                .disabled(!viewModel.canEndGame)
            }
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
