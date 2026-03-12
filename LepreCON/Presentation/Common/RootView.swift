import SwiftUI

struct RootView: View {
    private enum Screen {
        case home
        case game
        case results
    }

    @State private var currentScreen: Screen = .home

    var body: some View {
        switch currentScreen {
        case .home:
            HomeView(
                onStartGame: {
                    currentScreen = .game
                }
            )

        case .game:
            GameView(
                onFinishGame: {
                    currentScreen = .results
                }
            )

        case .results:
            ResultsView(
                onPlayAgain: {
                    currentScreen = .game
                },
                onBackToHome: {
                    currentScreen = .home
                }
            )
        }
    }
}

#Preview {
    RootView()
}

