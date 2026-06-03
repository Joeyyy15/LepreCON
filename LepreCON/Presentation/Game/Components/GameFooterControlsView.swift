//
// GameFooterControlsView.swift
// LepreCON
//
// Start Game and End Game controls at the bottom of the gameplay screen.
//

import SwiftUI

struct GameFooterControlsView: View {
    let showsControls: Bool
    let canStartGame: Bool
    let canEndGame: Bool
    var onStartGame: () -> Void = {}
    var onEndGame: () -> Void = {}

    var body: some View {
        HStack(spacing: 12) {
            if showsControls {
                Button("Start Game", action: onStartGame)
                    .buttonStyle(.borderedProminent)
                    .disabled(!canStartGame)

                Button("End Game", action: onEndGame)
                    .buttonStyle(.bordered)
                    .disabled(!canEndGame)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
