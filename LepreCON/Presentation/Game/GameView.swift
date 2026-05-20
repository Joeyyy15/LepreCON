import SwiftUI

@MainActor
struct GameView: View {
    @StateObject var viewModel: GameViewModel
    let onFinishGame: () -> Void

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
                GameBoardView()
                    .frame(maxWidth: .infinity)
                    .frame(height: 430)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .shadow(color: .black.opacity(0.18), radius: 10, x: 0, y: 6)

                VStack(spacing: 8) {
                    Text("Game Phase: \(viewModel.phaseDisplayText)")
                        .font(.headline)

                    Text("Current Player: \(viewModel.currentPlayerName ?? "Not started")")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                HStack(spacing: 12) {
                    Button("Start Game") {
                        viewModel.startGame()
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
            .padding()
        }
    }
}

#Preview {
    GameView(onFinishGame: {})
}

