//
// GameView.swift
// LepreCON
//
// Game screen: displays board state and forwards user actions to the ViewModel.
// Game rules live in the Domain layer, not in this view.
//

import SwiftUI

@MainActor
struct GameView: View {
    @StateObject var viewModel: GameViewModel
    let onFinishGame: () -> Void

    @State private var lastActionMessage: String?
    @State private var showsScoringSheet = false
    @State private var showsWhiteGemDecisionSheet = false
    @State private var showsResolutionSheet = false
    @State private var isDiscardContentsPresented = false
    @State private var deferResolutionSheet = false
    @State private var cupBoardAnchors: [Int: CupBoardAnchorInfo] = [:]
    @State private var didAutoStartGame = false
    @State private var isHandTrayPresented = false

    private var blocksGameplayInput: Bool {
        viewModel.isUnicornAnimationPlaying
    }

    /// Contents panel stays open while discard is required, or while the player is inspecting.
    private var showsDiscardContents: Bool {
        viewModel.shouldPresentDiscardContents || isDiscardContentsPresented
    }

    init(onFinishGame: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: GameViewModel())
        self.onFinishGame = onFinishGame
    }

    init(viewModel: GameViewModel, onFinishGame: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onFinishGame = onFinishGame
    }

    var body: some View {
        GeometryReader { geometry in
            let contentWidth = GameScreenLayout.contentWidth(in: geometry)
            let topPadding = GameScreenLayout.topContentPadding(in: geometry)
            let bottomPadding = GameScreenLayout.bottomContentPadding(in: geometry)

            // Use the real content width to size the image-based HUD bars.
            // This prevents top_bar from shrinking into the middle of the screen.
            let topBarHeight = GameScreenLayout.topBarHeight(forContentWidth: contentWidth)
            let dockHeight = GameScreenLayout.dockHeight(forContentWidth: contentWidth)

            let topReservedHeight = topPadding + topBarHeight + GameScreenLayout.hudToBoardGap
            let bottomReservedHeight = bottomPadding + dockHeight + GameScreenLayout.boardToDockGap
            let handTrayHeight = GameScreenLayout.handTrayHeight(screenHeight: geometry.size.height)
            let boardHeight = max(
                0,
                geometry.size.height - topReservedHeight - bottomReservedHeight
            )
            // Lowest playfield Y the downward discard tray may occupy (above dock).
            let discardTrayPlayfieldBottomLimit = max(
                0,
                geometry.size.height
                    - bottomPadding
                    - dockHeight
                    - GameScreenLayout.discardTrayDockClearance
                    - topReservedHeight
            )

            ZStack {
                // Middle gameplay layer.
                // This layer is centered inside the same screen-sized coordinate space
                // as the HUD and dock.
                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: topReservedHeight)

                    ZStack {
                        GameBoardView(
                            displayState: viewModel.boardDisplayState,
                            hideUnicornMarkers: viewModel.isUnicornAnimationPlaying,
                            discardCount: viewModel.discardCount,
                            discardGemCounts: viewModel.discardGemCounts,
                            isDiscardActiveDestination: viewModel.isDiscardRequired && !blocksGameplayInput,
                            isDiscardContentsPresented: showsDiscardContents && !blocksGameplayInput,
                            discardTrayPlayfieldBottomLimit: discardTrayPlayfieldBottomLimit,
                            onConfirmScore: confirmScore,
                            onTapDiscardPile: handleDiscardPileTap,
                            onDismissDiscardContents: {
                                isDiscardContentsPresented = false
                            }
                        )
                        .onPreferenceChange(CupBoardAnchorKey.self) { cupBoardAnchors = $0 }

                        if let script = viewModel.unicornAnimationScript {
                            UnicornAnimationOverlay(
                                script: script,
                                cupAnchors: cupBoardAnchors,
                                onFinished: handleUnicornAnimationFinished
                            )
                        }
                    }
                    .frame(width: contentWidth, height: boardHeight)

                    Spacer()
                        .frame(height: bottomReservedHeight)
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
                .zIndex(0)

                // Top and bottom chrome layer.
                // HUD and dock use the same content width as the board.
                VStack(spacing: 0) {
                    GameTopBarView(
                        hud: viewModel.boardDisplayState.hud,
                        canStartGame: viewModel.canStartGame,
                        canEndGame: viewModel.canEndGame,
                        showsGameControls: !viewModel.isGameOver,
                        onStartGame: startGame,
                        onEndGame: endGame
                    )
                    .frame(width: contentWidth, height: topBarHeight)
                    .padding(.top, topPadding)
                    .zIndex(2)

                    Spacer(minLength: 0)

                    // Hide toast while discard contents are open so it cannot cover gem cells.
                    GameActionFeedbackView(
                        message: showsDiscardContents ? nil : lastActionMessage
                    )
                        .frame(width: contentWidth, height: GameScreenLayout.actionFeedbackSlotHeight)

                    GameControlDockView(
                        handGemCounts: viewModel.boardDisplayState.handGemCounts,
                        currentRoll: viewModel.boardDisplayState.currentRoll,
                        showsRollControl: !viewModel.isGameOver,
                        canRollD12: viewModel.canRollD12 && !blocksGameplayInput,
                        canOpenHandTray: !blocksGameplayInput,
                        showsUndo: !viewModel.isGameOver,
                        canUndo: viewModel.canUndoLastPlacement && !blocksGameplayInput,
                        onRollD12: rollD12,
                        onUndo: {
                            viewModel.undoLastPlacement()
                            lastActionMessage = "Last placement undone."
                        },
                        onOpenHandTray: { isHandTrayPresented = true }
                    )
                    .frame(width: contentWidth, height: dockHeight)
                    .padding(.bottom, bottomPadding)
                    .zIndex(2)
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
                .zIndex(1)

                if isHandTrayPresented, !blocksGameplayInput {
                    HandTrayOverlayView(
                        gemCounts: viewModel.boardDisplayState.handGemCounts,
                        canPlace: viewModel.canPlaceFromHand,
                        isKindSelectable: { viewModel.canSelectHandGem(kind: $0) },
                        trayHeight: handTrayHeight,
                        onTapKind: placeHandGemFromTray,
                        onDismiss: { isHandTrayPresented = false }
                    )
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .zIndex(4)
                }

                if blocksGameplayInput {
                    Color.clear
                        .contentShape(Rectangle())
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .zIndex(5)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .background {
                // Background is decorative only. It should not participate in
                // the foreground HUD/board/dock layout.
                GameSceneBackgroundView()
            }
        }
        .sheet(isPresented: $showsScoringSheet) {
            GameScoringSheetView(
                rows: viewModel.boardDisplayState.pendingScoringCups,
                onConfirmScore: { cupIndex, color in
                    confirmScore(cupIndex: cupIndex, scoringColor: color)
                },
                onSkipScoring: {
                    skipScoring()
                    showsScoringSheet = false
                }
            )
        }
        .sheet(isPresented: $showsWhiteGemDecisionSheet) {
            if let pending = viewModel.pendingWhiteGemDecision {
                GameWhiteGemDecisionSheetView(
                    decision: pending,
                    cupLabel: pendingWhiteGemCupLabel,
                    onScoopAndContinue: { resolvePlacementChain(scoopAndContinue: true) },
                    onUseWhiteToEndTurn: { resolvePlacementChain(scoopAndContinue: false) },
                    onExplodeUnicorn: { resolveUnicornSpread(explode: true) },
                    onCalmUnicorn: { resolveUnicornSpread(explode: false) }
                )
                .id(pendingWhiteGemSheetID)
            }
        }
        .sheet(isPresented: $showsResolutionSheet) {
            resolutionSheet
        }
        .onChange(of: viewModel.boardDisplayState.pendingScoringCups) { _, cups in
            showsScoringSheet = !viewModel.isGameOver && !cups.isEmpty
        }
        .onChange(of: viewModel.pendingWhiteGemDecision) { _, pending in
            showsWhiteGemDecisionSheet = pending != nil && !viewModel.isGameOver
            if pending != nil {
                isHandTrayPresented = false
            }
        }
        .onChange(of: viewModel.resolutionEventPresentation) { _, presentation in
            guard presentation != nil else { return }
            if viewModel.isUnicornAnimationPlaying {
                deferResolutionSheet = true
            } else {
                showsResolutionSheet = true
            }
        }
        .onChange(of: viewModel.isUnicornAnimationPlaying) { _, isPlaying in
            if isPlaying {
                isHandTrayPresented = false
            }
        }
        .onChange(of: viewModel.isDiscardRequired) { _, isRequired in
            handleDiscardRequirementChanged(isRequired)
        }
        .overlay(alignment: .bottom) {
            gameOverBanner
        }
        .onAppear {
            guard !didAutoStartGame else { return }
            didAutoStartGame = true
            if viewModel.canStartGame {
                startGame()
            }
            showsWhiteGemDecisionSheet = viewModel.hasPendingWhiteGemDecision && !viewModel.isGameOver
        }
        .statusBarHidden(true)
    }

    @ViewBuilder
    private var gameOverBanner: some View {
        if let gameOver = viewModel.boardDisplayState.gameOver {
            VStack(spacing: 8) {
                Text("Game Over — Score \(gameOver.finalScore.totalPoints)")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(BoardStyle.hudValue)

                Button("Play Again") {
                    viewModel.startNewGame()
                    lastActionMessage = "New game started. Roll D12 to begin your turn."
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(BoardStyle.hudPanelFill.opacity(0.95))
            )
            .padding(
                .bottom,
                GameScreenLayout.dockHeight
                    + GameScreenLayout.actionFeedbackSlotHeight
                    + GameScreenLayout.boardToDockGap
                    + GameScreenLayout.bottomPadding
                    + 8
            )
        }
    }

    private var resolutionSheet: some View {
        NavigationStack {
            Group {
                if let presentation = viewModel.resolutionEventPresentation {
                    TurnResolutionEventsPanel(
                        presentation: presentation,
                        highlightedLineIndex: viewModel.highlightedResolutionLineIndex
                    )
                    .padding()
                }
            }
            .navigationTitle("Turn Events")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        showsResolutionSheet = false
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private func handleUnicornAnimationFinished() {
        viewModel.finishUnicornAnimation()
        if deferResolutionSheet, viewModel.resolutionEventPresentation != nil {
            showsResolutionSheet = true
            deferResolutionSheet = false
        }
    }

    // MARK: - Menu actions

    private func startGame() {
        viewModel.startGame()
        lastActionMessage = "Game started. Roll D12 to begin your turn."
    }

    private func endGame() {
        viewModel.endGame()
        onFinishGame()
    }

    // MARK: - Gameplay actions

    private func rollD12() {
        switch viewModel.rollD12AndBeginTurn() {
        case .success:
            lastActionMessage = "Rolled \(viewModel.session.currentRoll ?? 0). Tap a hand gem to place."
        case .failure(let error):
            lastActionMessage = turnErrorMessage(error)
        }
    }

    private func placeHandGemFromTray(_ kind: GemKind) {
        let discarding = viewModel.isDiscardRequired
        switch viewModel.placeHandGem(kind: kind) {
        case .success:
            if viewModel.session.isTurnPlacementComplete {
                isDiscardContentsPresented = false
                if viewModel.isInScoringChoicePhase {
                    lastActionMessage = "Placement finished. Score a cup or choose Skip Scoring."
                    showsScoringSheet = true
                } else {
                    lastActionMessage = "Placement finished. Roll D12 for your next turn."
                }
            } else if discarding {
                if !viewModel.isDiscardRequired {
                    isDiscardContentsPresented = false
                }
                lastActionMessage = "Discarded 1 gem. Continue placing from your hand."
            } else if viewModel.isDiscardRequired {
                lastActionMessage = "Full rotation complete. Discard 1 gem from your hand."
                isHandTrayPresented = true
            } else {
                lastActionMessage = "Gem placed. Continue placing from your hand."
            }
        case .failure(let error):
            lastActionMessage = turnErrorMessage(error)
        }
    }

    private func handleDiscardPileTap() {
        if viewModel.isDiscardRequired {
            // Contents already auto-presented; open hand so the player can choose a gem.
            isHandTrayPresented = true
            lastActionMessage = "Discard 1 gem from your hand into the discard pile."
            return
        }
        isDiscardContentsPresented.toggle()
    }

    private func handleDiscardRequirementChanged(_ isRequired: Bool) {
        guard !blocksGameplayInput else { return }
        if isRequired {
            isDiscardContentsPresented = true
            isHandTrayPresented = true
            lastActionMessage = "Full rotation complete. Discard 1 gem from your hand."
        } else {
            isDiscardContentsPresented = false
        }
    }

    private var pendingWhiteGemSheetID: String {
        guard let pending = viewModel.pendingWhiteGemDecision else { return "none" }
        switch pending {
        case .endPlacementChain(let cupIndex):
            return "chain-\(cupIndex)"
        case .stopUnicornSpread(let cupIndex):
            return "unicorn-\(cupIndex)"
        }
    }

    private var pendingWhiteGemCupLabel: String {
        guard let cupIndex = viewModel.pendingWhiteGemDecision?.cupIndex else {
            return "this cup"
        }
        return GameBoardDisplayState.cupLabel(forCupIndex: cupIndex, cups: viewModel.session.cups)
    }

    private func resolvePlacementChain(scoopAndContinue: Bool) {
        switch viewModel.resolvePlacementChainDecision(scoopAndContinue: scoopAndContinue) {
        case .success:
            showsWhiteGemDecisionSheet = viewModel.hasPendingWhiteGemDecision
            if scoopAndContinue {
                lastActionMessage = "Picked up the cup. Continue placing from your hand."
            } else if viewModel.hasPendingWhiteGemDecision {
                lastActionMessage = "Used a white gem to end the turn. Choose unicorn outcome."
            } else {
                lastActionMessage = "Used a white gem to end the turn."
            }
            if viewModel.isInScoringChoicePhase {
                showsScoringSheet = true
            }
        case .failure(let error):
            lastActionMessage = whiteGemDecisionErrorMessage(error)
        }
    }

    private func resolveUnicornSpread(explode: Bool) {
        switch viewModel.resolveUnicornSpreadDecision(explode: explode) {
        case .success:
            showsWhiteGemDecisionSheet = viewModel.hasPendingWhiteGemDecision
            lastActionMessage = explode
                ? "Unicorn exploded."
                : "Used a white gem to calm the unicorn."
            if viewModel.isInScoringChoicePhase {
                showsScoringSheet = true
            }
        case .failure(let error):
            lastActionMessage = whiteGemDecisionErrorMessage(error)
        }
    }

    private func confirmScore(cupIndex: Int, scoringColor: GemKind) {
        switch viewModel.confirmScore(cupIndex: cupIndex, scoringColor: scoringColor) {
        case .success:
            if viewModel.isInScoringChoicePhase {
                lastActionMessage = "Scored \(scoringColor.scoringDisplayName). Score another cup or choose Skip Scoring."
            } else {
                lastActionMessage = "Scored \(scoringColor.scoringDisplayName). Roll D12 when ready."
                showsScoringSheet = false
            }
        case .failure(let error):
            lastActionMessage = scoreConfirmationErrorMessage(error)
        }
    }

    private func skipScoring() {
        viewModel.skipScoringChoices()
        lastActionMessage = "Scoring skipped. Roll D12 when ready."
    }

    private func scoreConfirmationErrorMessage(_ error: ScoreConfirmationError) -> String {
        switch error {
        case .invalidCupIndex: return "Invalid cup."
        case .cupAlreadyCompleted: return "That cup is already scored."
        case .potOfGoldCannotScore: return "The Pot of Gold cannot be scored."
        case .noPendingScoreChoiceForCup: return "That cup has no pending score option."
        case .scoringCandidateNotAvailable: return "That scoring color is not available for this cup."
        case .potOfGoldMissing: return "Pot of Gold is missing from the board."
        }
    }

    private func turnErrorMessage(_ error: GameTurnError) -> String {
        switch error {
        case .gameNotPlaying: return "Start the game first."
        case .invalidRoll: return "Invalid roll."
        case .turnAlreadyInProgress: return "Finish the current turn before rolling again."
        case .noActiveTurn: return "Roll D12 and draw gems before placing."
        case .gemNotInHand: return "That gem is not in your hand."
        case .invalidPlacementCupIndex: return "Invalid cup for placement."
        case .placementRequiresDiscard: return "Discard one gem after completing a full rotation."
        case .discardNotRequired: return "Discard is only allowed after a full board rotation."
        case .cannotDiscardBlackGem: return "Poop gems cannot be discarded after a full rotation."
        case .cannotPlaceBlackGemWithUnicorn: return "Poop gems cannot be placed in the unicorn's cup."
        case .pendingScoreChoicesUnresolved: return "Score a cup or choose Skip Scoring before rolling again."
        case .pendingWhiteGemDecisionUnresolved: return "Resolve the white gem choice before continuing."
        }
    }

    private func whiteGemDecisionErrorMessage(_ error: WhiteGemDecisionError) -> String {
        switch error {
        case .gameNotPlaying: return "Start the game first."
        case .noPendingDecision: return "There is no white-gem decision to resolve."
        case .invalidCupIndex: return "Invalid cup for the white-gem decision."
        case .unexpectedDecisionKind: return "That choice does not apply to the current white-gem decision."
        case .whiteGemNotInCup: return "That cup no longer has a white gem."
        }
    }
}

#Preview {
    let viewModel = GameViewModel(playerNames: ["Player 1"])
    let _ = { viewModel.startGame() }()
    return GameView(viewModel: viewModel, onFinishGame: {})
}
