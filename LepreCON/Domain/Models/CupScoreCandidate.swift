//
// CupScoreCandidate.swift
// LepreCON
//
// One possible scoring outcome for a cup when evaluated against a rainbow color.
// A cup may have several candidates (e.g. enough gems to score as red or as blue).
//

import Foundation

/// A single scoring possibility for one cup and one rainbow color.
struct CupScoreCandidate: Equatable, Codable {
    /// The rainbow color being scored (red through purple).
    let scoringColor: GemKind
    /// Gems of the scoring color plus clear gems (clear counts as the chosen color).
    let goodCount: Int
    /// White and gold gems — passes that neither help nor blemish the score.
    let passCount: Int
    /// Off-color rainbow gems, pink, and black (poop resolution not implemented yet).
    let blemishCount: Int
    /// goodCount minus blemishCount. Must be >= 5 for a valid candidate.
    let adjustedGoodCount: Int
    /// True when the cup's board color matches the scoring color (matters for double points later).
    let isMatchingCupColor: Bool
}
