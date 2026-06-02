//
// CompletedColorScore.swift
// LepreCON
//
// Best final score earned for one rainbow color across completed cups.
//

import Foundation

/// One rainbow color’s contribution to the final score.
struct CompletedColorScore: Equatable, Codable {
    let color: GemKind
    let points: Int
    let wasMatchingCupColor: Bool
    let cupIndex: Int
}
