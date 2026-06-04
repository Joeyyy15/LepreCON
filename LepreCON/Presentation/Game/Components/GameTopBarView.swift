//
// GameTopBarView.swift
// LepreCON
//
// Top HUD: centered top_bar with anchored overlays (Score | Bag | Magic | Rainbow | Settings).
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
        GeometryReader { geometry in
            let barWidth = geometry.size.width
            let barHeight = geometry.size.height
            let progressWidth = barWidth * HUDBarArtLayout.topRainbowProgressWidthFraction

            ZStack(alignment: .topLeading) {
                TopBarArtBackground()

                topLabel("Score", centerX: HUDBarArtLayout.topScoreCenterX, barWidth: barWidth, barHeight: barHeight)
                statValue("\(hud.totalScore)", centerX: HUDBarArtLayout.topScoreCenterX, barWidth: barWidth, barHeight: barHeight, compact: true)

                topLabel("Bag", centerX: HUDBarArtLayout.topBagCenterX, barWidth: barWidth, barHeight: barHeight)
                statValue("\(hud.gemsInBag)", centerX: HUDBarArtLayout.topBagCenterX, barWidth: barWidth, barHeight: barHeight, compact: true)

                MagicSlotPlaceholderView()
                    .hudBarPosition(
                        width: barWidth,
                        height: barHeight,
                        centerX: HUDBarArtLayout.topMagicCenterX,
                        centerY: HUDBarArtLayout.topMagicBlockY
                    )

                topLabel("Rainbow", centerX: HUDBarArtLayout.topRainbowCenterX, barWidth: barWidth, barHeight: barHeight)
                statValue(
                    "\(hud.rainbowCompleted)/\(hud.rainbowTotal)",
                    centerX: HUDBarArtLayout.topRainbowCenterX,
                    barWidth: barWidth,
                    barHeight: barHeight,
                    centerY: HUDBarArtLayout.topRainbowValueY,
                    compact: false
                )

                RainbowHUDProgressBar(progress: rainbowProgressFraction)
                    .frame(width: progressWidth)
                    .hudBarPosition(
                        width: barWidth,
                        height: barHeight,
                        centerX: HUDBarArtLayout.topRainbowCenterX,
                        centerY: HUDBarArtLayout.topRainbowProgressY
                    )

                settingsControl
                    .hudBarPosition(
                        width: barWidth,
                        height: barHeight,
                        centerX: HUDBarArtLayout.topSettingsCenterX,
                        centerY: HUDBarArtLayout.topMagicBlockY
                    )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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

    private var rainbowProgressFraction: Double {
        guard hud.rainbowTotal > 0 else { return 0 }
        return min(1, max(0, Double(hud.rainbowCompleted) / Double(hud.rainbowTotal)))
    }

    private func topLabel(
        _ text: String,
        centerX: CGFloat,
        barWidth: CGFloat,
        barHeight: CGFloat
    ) -> some View {
        HUDSectionLabel(text: text)
            .hudBarPosition(
                width: barWidth,
                height: barHeight,
                centerX: centerX,
                centerY: HUDBarArtLayout.topSectionLabelY
            )
    }

    @ViewBuilder
    private func statValue(
        _ value: String,
        centerX: CGFloat,
        barWidth: CGFloat,
        barHeight: CGFloat,
        centerY: CGFloat = HUDBarArtLayout.topSmallValueY,
        compact: Bool
    ) -> some View {
        Text(value)
            .font(compact ? HUDFantasyText.compactValueFont : HUDFantasyText.valueFont)
            .foregroundStyle(HUDFantasyText.valueColor)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .hudReadableShadow()
            .hudBarPosition(
                width: barWidth,
                height: barHeight,
                centerX: centerX,
                centerY: centerY
            )
    }

    private var settingsControl: some View {
        SettingsMenuButton(buttonSize: HUDBarArtLayout.topSettingsButtonSize) {
            if showsGameControls {
                if canStartGame {
                    Button("Start Game", action: onStartGame)
                }

                Button("End Game", role: .destructive) {
                    showsEndGameConfirmation = true
                }
                .disabled(!canEndGame)
            }

            Button("Rules & Help") {
                showsRulesPlaceholder = true
            }
        }
    }
}

#Preview("Game Top Bar") {
    GameTopBarView(
        hud: GameHUDDisplay(
            rainbowCompleted: 0,
            rainbowTotal: 6,
            gemsInBag: 82,
            goldInPot: 2,
            goldCapacity: 9,
            totalScore: 0
        ),
        canStartGame: true,
        canEndGame: true,
        showsGameControls: true
    )
    .frame(width: 360, height: GameScreenLayout.topBarHeight)
    .padding()
    .background(Color.green.opacity(0.25))
}
