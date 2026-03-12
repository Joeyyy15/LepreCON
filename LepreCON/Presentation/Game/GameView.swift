import SwiftUI

struct GameView: View {
    @StateObject var viewModel: GameViewModel
    let onFinishGame: () -> Void

    init(viewModel: GameViewModel = GameViewModel(), onFinishGame: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onFinishGame = onFinishGame
    }

    var body: some View {
        VStack(spacing: 24) {
            Text("Game screen coming soon")
                .font(.title2.weight(.semibold))

            Button("End Game (placeholder)") {
                onFinishGame()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

#Preview {
    GameView(onFinishGame: {})
}

