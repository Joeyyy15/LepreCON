//
// GameTopBarView.swift
// LepreCON
//
// Top bar: stat boxes centered as a group; settings gear overlaid on the right.
//

import SwiftUI

struct GameTopBarView: View {
    let hud: GameHUDDisplay
    let canStartGame: Bool
    let canEndGame: Bool
    let showsGameControls: Bool

    var onStartGame: () -> Void = {}
    var onEndGame: () -> Void = {}

    @State private var showsEndGameConfirmation = false
    @State private var showsRulesPlaceholder = false

    var body: some View {
        ZStack {
            GameHUDView(hud: hud, style: .embedded)
                .frame(maxWidth: .infinity)

            HStack {
                Spacer(minLength: 0)
                settingsMenuButton
                    .padding(.trailing, GameScreenLayout.gearTrailingPadding)
            }
        }
        .padding(.vertical, 6)
        .frame(height: GameScreenLayout.topBarHeight)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: BoardStyle.sceneChromeRadius, style: .continuous)
                .fill(BoardStyle.hudPanelFill)
        )
        .overlay(
            RoundedRectangle(cornerRadius: BoardStyle.sceneChromeRadius, style: .continuous)
                .stroke(BoardStyle.dockPanelStroke, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.22), radius: 4, x: 0, y: 2)
        .gameScreenDebugBorder(.yellow)
        .confirmationDialog(
            "End this game?",
            isPresented: $showsEndGameConfirmation,
            titleVisibility: .visible
        ) {
            Button("End Game", role: .destructive, action: onEndGame)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Your progress will stop and you will leave the game screen.")
        }
        .alert("Rules & Help", isPresented: $showsRulesPlaceholder) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Full rules and help content will be added in a future update.")
        }
    }

    private var settingsMenuButton: some View {
        Menu {
            if showsGameControls {
                Button("Start Game", action: onStartGame)
                    .disabled(!canStartGame)

                Button("End Game", role: .destructive) {
                    showsEndGameConfirmation = true
                }
                .disabled(!canEndGame)
            }

            Button("Rules & Help") {
                showsRulesPlaceholder = true
            }
        } label: {
            Image(systemName: "gearshape.fill")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(BoardStyle.hudValue)
                .frame(width: 36, height: 36)
                .background(
                    Circle()
                        .fill(BoardStyle.hudBadgeFill)
                )
                .overlay(
                    Circle()
                        .stroke(BoardStyle.hudBadgeStroke, lineWidth: 0.75)
                )
                .accessibilityLabel("Game menu")
        }
    }
}

#Preview("Game Top Bar") {
    GameTopBarView(
        hud: GameHUDDisplay(
            rainbowCompleted: 1,
            rainbowTotal: 6,
            gemsInBag: 72,
            goldInPot: 2,
            goldCapacity: 9,
            totalScore: 8
        ),
        canStartGame: true,
        canEndGame: true,
        showsGameControls: true
    )
    .padding()
    .background(Color.green.opacity(0.25))
}
