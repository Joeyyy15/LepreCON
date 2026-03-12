import SwiftUI

struct ResultsView: View {
    @StateObject var viewModel: ResultsViewModel
    let onPlayAgain: () -> Void
    let onBackToHome: () -> Void

    init(
        viewModel: ResultsViewModel = ResultsViewModel(),
        onPlayAgain: @escaping () -> Void,
        onBackToHome: @escaping () -> Void
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onPlayAgain = onPlayAgain
        self.onBackToHome = onBackToHome
    }

    var body: some View {
        VStack(spacing: 24) {
            Text("Results screen coming soon")
                .font(.title2.weight(.semibold))

            Button("Play Again") {
                onPlayAgain()
            }
            .buttonStyle(.borderedProminent)

            Button("Back to Home") {
                onBackToHome()
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }
}

#Preview {
    ResultsView(onPlayAgain: {}, onBackToHome: {})
}

