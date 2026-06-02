//
// FinalScoreResult.swift
// LepreCON
//
// Snapshot of end-game scoring from completed cups and the Pot of Gold.
//

import Foundation

/// Full final score breakdown for the current session.
struct FinalScoreResult: Equatable, Codable {
    let isRainbowComplete: Bool
    let completedColorScores: [CompletedColorScore]
    let colorPoints: Int
    let goldPoints: Int
    let unicornPoints: Int
    let totalPoints: Int
    let rank: ScoreRank
    let missingColors: [GemKind]
    let goldCountInPot: Int
    let unicornCaptured: Bool
}
