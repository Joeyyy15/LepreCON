//
// UnicornResolutionAnimator.swift
// LepreCON
//
// Drives timed unicorn + gem overlay playback from a read-only animation script.
//

import Combine
import SwiftUI

@MainActor
final class UnicornResolutionAnimator: ObservableObject {

    struct DroppingGemDisplay: Equatable {
        let imageName: String
        let position: CGPoint
        let dropProgress: CGFloat
    }

    struct CalmingGemDisplay: Equatable {
        let imageName: String
        let position: CGPoint
        let riseProgress: CGFloat
    }

    @Published private(set) var unicornPosition: CGPoint?
    @Published private(set) var activeCupIndex: Int?
    @Published private(set) var carriedGemImageName: String?
    @Published private(set) var droppingGem: DroppingGemDisplay?
    @Published private(set) var calmingGem: CalmingGemDisplay?
    @Published private(set) var isPlaying = false

    private var playbackTask: Task<Void, Never>?

    func cancel() {
        playbackTask?.cancel()
        playbackTask = nil
        resetVisualState()
        isPlaying = false
    }

    func play(
        script: UnicornAnimationScript,
        cupAnchors: [Int: CupBoardAnchorInfo],
        onComplete: @escaping () -> Void
    ) {
        cancel()
        isPlaying = true

        playbackTask = Task { [weak self] in
            guard let self else { return }
            await run(script: script, cupAnchors: cupAnchors)
            guard !Task.isCancelled else { return }
            resetVisualState()
            isPlaying = false
            onComplete()
        }
    }

    private func resetVisualState() {
        unicornPosition = nil
        activeCupIndex = nil
        carriedGemImageName = nil
        droppingGem = nil
        calmingGem = nil
    }

    private func run(script: UnicornAnimationScript, cupAnchors: [Int: CupBoardAnchorInfo]) async {
        guard let startAnchor = cupAnchors[script.startCupIndex] else { return }
        activeCupIndex = script.startCupIndex
        unicornPosition = UnicornCupDisplayLayout.unicornHoverPosition(
            for: startAnchor,
            cupIndex: script.startCupIndex
        )

        if script.steps.isEmpty {
            try? await Task.sleep(nanoseconds: Self.nanoseconds(UnicornAnimationTiming.emptyExplosionHoldSeconds))
            return
        }

        for step in script.steps {
            guard !Task.isCancelled else { return }

            switch step {
            case .calmAtCup(let cupIndex):
                guard let anchor = cupAnchors[cupIndex] else { continue }
                activeCupIndex = cupIndex
                unicornPosition = UnicornCupDisplayLayout.unicornHoverPosition(
                    for: anchor,
                    cupIndex: cupIndex
                )
                await playCalmEffect(
                    at: UnicornCupDisplayLayout.gemInteractionCenter(for: anchor)
                )

            case .carryGemToCup(let gemKind, let toCupIndex):
                guard let destAnchor = cupAnchors[toCupIndex] else { continue }
                let destHover = UnicornCupDisplayLayout.unicornHoverPosition(
                    for: destAnchor,
                    cupIndex: toCupIndex
                )
                let dropCenter = UnicornCupDisplayLayout.gemInteractionCenter(for: destAnchor)
                let origin = unicornPosition ?? destHover
                activeCupIndex = toCupIndex
                carriedGemImageName = gemKind.imageAssetName
                await animateTravel(from: origin, to: destHover, duration: UnicornAnimationTiming.travelSeconds)
                carriedGemImageName = nil
                await animateGemDrop(
                    imageName: gemKind.imageAssetName,
                    at: dropCenter,
                    duration: UnicornAnimationTiming.dropSeconds
                )
                unicornPosition = destHover
                try? await Task.sleep(nanoseconds: Self.nanoseconds(UnicornAnimationTiming.stepPauseSeconds))
            }
        }
    }

    private func playCalmEffect(at gemCenter: CGPoint) async {
        let imageName = GemKind.white.imageAssetName
        let frames = 24
        for frame in 0...frames {
            guard !Task.isCancelled else { return }
            let progress = CGFloat(frame) / CGFloat(frames)
            calmingGem = CalmingGemDisplay(
                imageName: imageName,
                position: gemCenter,
                riseProgress: progress
            )
            try? await Task.sleep(nanoseconds: Self.nanoseconds(UnicornAnimationTiming.calmHoldSeconds / Double(frames)))
        }
        calmingGem = nil
    }

    private func animateTravel(from origin: CGPoint, to destination: CGPoint, duration: Double) async {
        let frames = max(1, Int(duration * 60))
        for frame in 0...frames {
            guard !Task.isCancelled else { return }
            let raw = Double(frame) / Double(frames)
            let eased = Self.easeInOut(raw)
            unicornPosition = Self.lerp(origin, destination, eased)
            try? await Task.sleep(nanoseconds: Self.nanoseconds(duration / Double(frames)))
        }
        unicornPosition = destination
    }

    private func animateGemDrop(imageName: String, at cupCenter: CGPoint, duration: Double) async {
        let frames = max(1, Int(duration * 60))
        for frame in 0...frames {
            guard !Task.isCancelled else { return }
            let progress = CGFloat(frame) / CGFloat(frames)
            droppingGem = DroppingGemDisplay(
                imageName: imageName,
                position: cupCenter,
                dropProgress: progress
            )
            try? await Task.sleep(nanoseconds: Self.nanoseconds(duration / Double(frames)))
        }
        droppingGem = nil
    }

    private static func lerp(_ from: CGPoint, _ to: CGPoint, _ t: Double) -> CGPoint {
        CGPoint(
            x: from.x + (to.x - from.x) * t,
            y: from.y + (to.y - from.y) * t
        )
    }

    private static func easeInOut(_ t: Double) -> Double {
        t < 0.5 ? 2 * t * t : 1 - pow(-2 * t + 2, 2) / 2
    }

    private static func nanoseconds(_ seconds: Double) -> UInt64 {
        UInt64(seconds * 1_000_000_000)
    }
}
