//
// GameStatusMessageView.swift
// LepreCON
//
// Player, unicorn, placement guidance, game-over summary, and rainbow status.
//

import SwiftUI

struct GameStatusMessageView: View {
    let playerName: String?
    let placementGuidance: String?
    let unicornStatusLine: String
    let unicornIsCaptured: Bool
    let gameOver: GameOverDisplay?
    let showRainbowCompleteMessage: Bool
    var onPlayAgain: () -> Void = {}

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let playerName {
                Text(playerName)
                    .font(.subheadline.weight(.semibold))
            }

            if let placementGuidance {
                Text(placementGuidance)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text(unicornStatusLine)
                .font(.caption)
                .foregroundStyle(unicornIsCaptured ? .green : .secondary)

            if let gameOver {
                gameOverSection(gameOver)
            } else if showRainbowCompleteMessage {
                Text("Rainbow complete — keep playing until the game ends.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private func gameOverSection(_ gameOver: GameOverDisplay) -> some View {
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

            Button("Play Again", action: onPlayAgain)
                .buttonStyle(.borderedProminent)
                .padding(.top, 4)
        }
    }
}
