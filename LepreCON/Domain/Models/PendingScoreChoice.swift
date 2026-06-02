//
// PendingScoreChoice.swift
// LepreCON
//
// A cup that could score after placement ends. The player chooses later whether to score.
// Nothing is completed automatically — this only records available options.
//

import Foundation

/// One cup with one or more valid scoring colors the player may choose to score later.
struct PendingScoreChoice: Equatable, Codable {
    /// Index into `GameSession.cups` for the scoreable cup/lane.
    let cupIndex: Int
    /// Every valid scoring color for this cup. The player picks one later (not implemented yet).
    let candidates: [CupScoreCandidate]
}
