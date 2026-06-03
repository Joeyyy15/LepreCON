//
// GameBottomControlsAreaView.swift
// LepreCON
//
// Compact bottom play zone: roll, hand, and conditional scoring helpers.
//

import SwiftUI

struct GameBottomControlsAreaView: View {
    let boardDisplayState: GameBoardDisplayState
    let isGameOver: Bool
    let canRollD12: Bool
    let canPlaceFromHand: Bool
    let canUndoLastPlacement: Bool
    let emptyHandMessage: String
    let playerName: String?
    let placementGuidance: String?
    let showRainbowCompleteMessage: Bool
    let resolutionPresentation: TurnResolutionEventPresentation?
    let highlightedResolutionLineIndex: Int?

    var onRollD12: () -> Void = {}
    var onTapHandGemKind: (GemKind) -> Void = { _ in }
    var onUndoLastPlacement: () -> Void = {}
    var onConfirmScore: (Int, GemKind) -> Void = { _, _ in }
    var onSkipScoring: () -> Void = {}
    var onPlayAgain: () -> Void = {}

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 8) {
                if showsCompactStatus {
                    GameStatusMessageView(
                        playerName: playerName,
                        placementGuidance: placementGuidance,
                        unicornStatusLine: boardDisplayState.unicornStatus.statusLine,
                        unicornIsCaptured: boardDisplayState.unicornStatus.isCaptured,
                        gameOver: boardDisplayState.gameOver,
                        showRainbowCompleteMessage: showRainbowCompleteMessage,
                        onPlayAgain: onPlayAgain
                    )
                }

                if !isGameOver, !boardDisplayState.pendingScoringCups.isEmpty {
                    CupScoringControlsSection(
                        rows: boardDisplayState.pendingScoringCups,
                        onConfirmScore: onConfirmScore,
                        onSkipScoring: onSkipScoring
                    )
                }

                if let resolutionPresentation {
                    TurnResolutionEventsPanel(
                        presentation: resolutionPresentation,
                        highlightedLineIndex: highlightedResolutionLineIndex
                    )
                }

                GameActionAreaView(
                    showsRollButton: !isGameOver,
                    canRollD12: canRollD12,
                    onRollD12: onRollD12
                )

                HandPanelView(
                    handGemCounts: boardDisplayState.handGemCounts,
                    emptyHandMessage: emptyHandMessage,
                    canPlaceFromHand: canPlaceFromHand,
                    showsUndo: !isGameOver,
                    canUndoLastPlacement: canUndoLastPlacement,
                    onTapHandGemKind: onTapHandGemKind,
                    onUndoLastPlacement: onUndoLastPlacement
                )

                if showsDiscardPile {
                    DiscardPileView(gemCounts: boardDisplayState.discardGemCounts)
                }
            }
            .padding(.horizontal, 4)
            .padding(.vertical, 4)
        }
    }

    private var showsCompactStatus: Bool {
        boardDisplayState.gameOver != nil
            || showRainbowCompleteMessage
            || placementGuidance != nil
    }

    /// Shown on game over only so normal play stays compact.
    private var showsDiscardPile: Bool {
        boardDisplayState.gameOver != nil && !boardDisplayState.discardGemCounts.isEmpty
    }
}
