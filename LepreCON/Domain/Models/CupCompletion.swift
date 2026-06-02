//
// CupCompletion.swift
// LepreCON
//
// Records that a cup/lane has scored and is no longer available for placement.
// The cup stays on the board for display; completion marks it as "removed" for turn logic.
//

import Foundation

/// Snapshot of how a cup scored. Stored on the cup after scoring is resolved (not wired yet).
struct CupCompletion: Equatable, Codable {
    /// Rainbow color that was scored on this cup (may differ from the cup's board color).
    let scoredColor: GemKind
    /// True when the cup's board color matched the scored color (double points later).
    let wasMatchingCupColor: Bool
    let goodCount: Int
    let passCount: Int
    let blemishCount: Int
    let adjustedGoodCount: Int
}

extension CupCompletion {
    /// Builds completion from a player-selected pending score candidate.
    init(from candidate: CupScoreCandidate) {
        self.init(
            scoredColor: candidate.scoringColor,
            wasMatchingCupColor: candidate.isMatchingCupColor,
            goodCount: candidate.goodCount,
            passCount: candidate.passCount,
            blemishCount: candidate.blemishCount,
            adjustedGoodCount: candidate.adjustedGoodCount
        )
    }
}
