//
// UnicornCupDisplayLayout.swift
// LepreCON
//
// Presentation-only hover offsets and active-cup highlights for unicorn animation.
//

import SwiftUI

enum UnicornCupSlotKind: Equatable {
    case rainbowLane
    case cloud
    case pot
}

enum UnicornCupDisplayLayout {

    private static let cloudCupIndices: Set<Int> = [0, 1, 8, 9]

    static func slotKind(forCupIndex cupIndex: Int) -> UnicornCupSlotKind {
        if cupIndex == GameSetup.potOfGoldCupIndex {
            return .pot
        }
        if cloudCupIndices.contains(cupIndex) {
            return .cloud
        }
        return .rainbowLane
    }

    /// Where the unicorn head should hover so it does not cover the gem stack.
    static func unicornHoverPosition(
        for anchor: CupBoardAnchorInfo,
        cupIndex: Int,
        unicornSize: CGFloat = UnicornIndicatorView.markerSize
    ) -> CGPoint {
        switch slotKind(forCupIndex: cupIndex) {
        case .rainbowLane:
            return CGPoint(
                x: anchor.bounds.midX,
                y: anchor.bounds.minY - unicornSize * 0.22
            )
        case .cloud:
            return CGPoint(
                x: anchor.bounds.midX + anchor.bounds.width * 0.14,
                y: anchor.bounds.minY - unicornSize * 0.34
            )
        case .pot:
            return CGPoint(
                x: anchor.bounds.midX,
                y: anchor.bounds.minY - unicornSize * 0.3
            )
        }
    }

    /// Where gems land / rise — the actual cup center (unchanged from anchor).
    static func gemInteractionCenter(for anchor: CupBoardAnchorInfo) -> CGPoint {
        anchor.center
    }
}

// MARK: - Active cup highlight

struct ActiveCupHighlightView: View {
    let kind: UnicornCupSlotKind
    let bounds: CGRect

    @State private var pulsePhase = false

    var body: some View {
        highlightShape
            .frame(width: bounds.width, height: bounds.height)
            .position(x: bounds.midX, y: bounds.midY)
            .scaleEffect(pulsePhase ? 1.03 : 0.97)
            .opacity(pulsePhase ? 0.92 : 0.55)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.62).repeatForever(autoreverses: true)) {
                    pulsePhase = true
                }
            }
    }

    @ViewBuilder
    private var highlightShape: some View {
        switch kind {
        case .rainbowLane:
            RoundedRectangle(cornerRadius: min(10, bounds.width * 0.2), style: .continuous)
                .stroke(highlightGradient, lineWidth: 2.5)
                .background(
                    RoundedRectangle(cornerRadius: min(10, bounds.width * 0.2), style: .continuous)
                        .fill(Color.yellow.opacity(0.12))
                )
                .shadow(color: Color.yellow.opacity(0.55), radius: pulsePhase ? 10 : 6)
        case .cloud, .pot:
            Ellipse()
                .stroke(highlightGradient, lineWidth: 2.5)
                .background(Ellipse().fill(Color.yellow.opacity(0.1)))
                .shadow(color: Color.orange.opacity(0.45), radius: pulsePhase ? 12 : 7)
        }
    }

    private var highlightGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.yellow.opacity(0.95),
                Color.orange.opacity(0.75)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
