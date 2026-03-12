import SwiftUI

struct HomeView: View {
    @StateObject var viewModel: HomeViewModel
    let onStartGame: () -> Void

    private let background = Color(red: 0.04, green: 0.20, blue: 0.12) // dark green
    private let accent = Color(red: 0.55, green: 0.93, blue: 0.68)     // bright green

    init(
        viewModel: HomeViewModel = HomeViewModel(),
        onStartGame: @escaping () -> Void
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onStartGame = onStartGame
    }

    var body: some View {
        ZStack {
            background.ignoresSafeArea()

            VStack(spacing: 24) {
                VStack(spacing: 10) {
                    Text("LepreCON")
                        .font(.system(size: 44, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Text("A wild Irish-themed party game")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(.white.opacity(0.85))
                        .multilineTextAlignment(.center)
                }

                VStack(spacing: 14) {
                    Button {
                        onStartGame()
                    } label: {
                        Text("Start Game")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                    }
                    .buttonStyle(PrimaryButtonStyle(background: accent))

                    Button {
                        // Placeholder: rules / how-to flow can be added later.
                    } label: {
                        Text("How to Play")
                            .font(.subheadline.weight(.semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    }
                    .buttonStyle(SecondaryButtonStyle(accent: accent))
                }
                .frame(maxWidth: 320)
                .padding(.top, 8)
            }
            .padding(32)
        }
    }
}

private struct PrimaryButtonStyle: ButtonStyle {
    let background: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(Color.black.opacity(0.9))
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(background)
            )
            .shadow(color: .black.opacity(0.25), radius: 14, x: 0, y: 10)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

private struct SecondaryButtonStyle: ButtonStyle {
    let accent: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(.white)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(accent.opacity(0.85), lineWidth: 1)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color.white.opacity(configuration.isPressed ? 0.10 : 0.06))
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

#Preview {
    HomeView(onStartGame: {})
}
