//
// ScoringResult.swift
// LepreCON
//
// All valid scoring candidates for one cup after evaluation.
//

import Foundation

/// Outcome of scoring evaluation for a single cup.
struct ScoringResult: Equatable {
    /// Every rainbow color this cup can score as (adjustedGoodCount >= 5).
    /// Empty for the Pot of Gold or when no color qualifies.
    let candidates: [CupScoreCandidate]
}
