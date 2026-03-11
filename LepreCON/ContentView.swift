import SwiftUI

struct ContentView: View {
    private let background = Color(red: 0.04, green: 0.20, blue: 0.12) // dark green
    private let accent = Color(red: 0.55, green: 0.93, blue: 0.68)     // bright green

    private enum Screen {
        case home
        case game
        case howToPlay
    }

    @State private var currentScreen: Screen = .home

    var body: some View {
        ZStack {
            background.ignoresSafeArea()

            switch currentScreen {
            case .home:
                homeScreen
            case .game:
                gameScreen
            case .howToPlay:
                howToPlayScreen
            }
        }
    }

    private var homeScreen: some View {
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
                    currentScreen = .game
                } label: {
                    Text("Start Game")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
                .buttonStyle(PrimaryButtonStyle(background: accent))

                Button {
                    currentScreen = .howToPlay
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

    private var gameScreen: some View {
        VStack(spacing: 24) {
            topBar

            Spacer()

            Text("Game screen coming soon")
                .font(.title2.weight(.semibold))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Spacer()
        }
        .padding(24)
    }

    private var howToPlayScreen: some View {
        VStack(spacing: 24) {
            topBar

            VStack(alignment: .leading, spacing: 12) {
                Text("How to Play")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.white)

                VStack(alignment: .leading, spacing: 8) {
                    Text("1. Gather your bravest party crew.")
                    Text("2. Take turns drawing wild LepreCON challenges.")
                    Text("3. Earn the most shamrocks to win the night.")
                }
                .font(.body)
                .foregroundStyle(.white.opacity(0.9))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.white.opacity(0.06))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(accent.opacity(0.4), lineWidth: 1)
                    )
            )

            Spacer()
        }
        .padding(24)
    }

    private var topBar: some View {
        HStack {
            Button {
                currentScreen = .home
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left")
                    Text("Home")
                }
                .font(.subheadline.weight(.semibold))
            }
            .foregroundStyle(accent)

            Spacer()
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
    ContentView()
}
