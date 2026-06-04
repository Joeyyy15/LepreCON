//
// UnicornAnimationOverlay.swift
// LepreCON
//
// Full-board overlay that replays unicorn resolution using lane anchor positions.
//

import SwiftUI

struct UnicornAnimationOverlay: View {
    let script: UnicornAnimationScript
    let cupAnchors: [Int: CupBoardAnchorInfo]
    let onFinished: () -> Void

    @StateObject private var animator = UnicornResolutionAnimator()
    @State private var didStartPlayback = false

    private let unicornSize = UnicornIndicatorView.markerSize
    private let carriedGemSize: CGFloat = 34
    private let dropGemSize: CGFloat = 36

    var body: some View {
        ZStack {
            Color.black.opacity(0.08)
                .ignoresSafeArea()

            if let activeIndex = animator.activeCupIndex,
               let anchor = cupAnchors[activeIndex] {
                ActiveCupHighlightView(
                    kind: UnicornCupDisplayLayout.slotKind(forCupIndex: activeIndex),
                    bounds: anchor.bounds
                )
            }

            if let drop = animator.droppingGem {
                GemView(imageName: drop.imageName, size: dropGemSize)
                    .scaleEffect(0.85 + drop.dropProgress * 0.15)
                    .opacity(0.35 + drop.dropProgress * 0.65)
                    .position(
                        x: drop.position.x,
                        y: drop.position.y + drop.dropProgress * 14
                    )
            }

            if let calm = animator.calmingGem {
                GemView(imageName: calm.imageName, size: carriedGemSize)
                    .opacity(1 - Double(calm.riseProgress) * 0.85)
                    .position(
                        x: calm.position.x,
                        y: calm.position.y - calm.riseProgress * 28
                    )
            }

            if let position = animator.unicornPosition {
                unicornHead(at: position)

                if let carried = animator.carriedGemImageName {
                    GemView(imageName: carried, size: carriedGemSize)
                        .position(x: position.x, y: position.y - unicornSize * 0.38)
                }
            }
        }
        .contentShape(Rectangle())
        .allowsHitTesting(true)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Unicorn resolution animation")
        .onAppear { startPlaybackIfReady() }
        .onChange(of: cupAnchors) { _, _ in startPlaybackIfReady() }
        .onDisappear { animator.cancel() }
    }

    @ViewBuilder
    private func unicornHead(at position: CGPoint) -> some View {
        Image("unicorn")
            .resizable()
            .scaledToFit()
            .frame(width: unicornSize, height: unicornSize)
            .shadow(color: .black.opacity(0.35), radius: 4, x: 0, y: 2)
            .shadow(color: .white.opacity(0.35), radius: 2, x: 0, y: 0)
            .position(position)
    }

    private func startPlaybackIfReady() {
        guard !didStartPlayback else { return }
        guard cupAnchors[script.startCupIndex] != nil else { return }
        didStartPlayback = true

        animator.play(script: script, cupAnchors: cupAnchors, onComplete: onFinished)
    }
}
