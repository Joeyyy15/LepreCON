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
        VStack(spacing: 24) {
            Text("Game screen coming soon")
                .font(.title2.weight(.semibold))

            VStack(spacing: 8) {
                Text("Game Phase: \(viewModel.session.phase.rawValue)")
                    .font(.headline)

                Text("Current Player: \(viewModel.currentPlayerName ?? "Not started")")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Button("Start Game") {
                viewModel.startGame()
            }
            .buttonStyle(.borderedProminent)

            Button("End Game") {
                viewModel.endGame()
                onFinishGame()
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }
}

#Preview {
    GameView(onFinishGame: {})
}

