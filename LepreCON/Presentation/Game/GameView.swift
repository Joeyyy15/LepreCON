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
                GameBoardView(displayState: viewModel.boardDisplayState)
                    .frame(maxWidth: .infinity)
                    .frame(height: 380)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .shadow(color: .black.opacity(0.18), radius: 10, x: 0, y: 6)

                statusSection
                turnControlsSection
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

            if viewModel.boardDisplayState.isTurnPlacementComplete {
                Text("Placement complete — roll again to start next turn")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
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

            if viewModel.boardDisplayState.handGems.isEmpty {
                Text(viewModel.canRollD12 ? "Roll D12 to draw gems" : "No gems in hand")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                HandGemsView(
                    gems: viewModel.boardDisplayState.handGems,
                    canPlace: viewModel.canPlaceFromHand,
                    onTapGem: placeHandGemInCurrentCup
                )
            }

            if viewModel.canPlaceFromHand {
                Text("Tap a gem to place it in the highlighted cup")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var discardSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Discard Pile")
                .font(.headline)

            if viewModel.boardDisplayState.discardGems.isEmpty {
                Text("Empty")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                HandGemsView(
                    gems: viewModel.boardDisplayState.discardGems,
                    isInteractive: false
                )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var gameControlsSection: some View {
        HStack(spacing: 12) {
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

    private func placeHandGemInCurrentCup(gemID: UUID) {
        switch viewModel.placeGemInCurrentCup(gemID: gemID) {
        case .success:
            if viewModel.session.isTurnPlacementComplete {
                lastActionMessage = "Placement finished. Roll D12 for your next turn."
            } else {
                lastActionMessage = "Gem placed. Continue placing from your hand."
            }
        case .failure(let error):
            lastActionMessage = turnErrorMessage(error)
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
        }
    }
}

#Preview {
    let viewModel = GameViewModel(playerNames: ["Player 1"])
    let _ = { viewModel.startGame() }()
    return GameView(viewModel: viewModel, onFinishGame: {})
}
