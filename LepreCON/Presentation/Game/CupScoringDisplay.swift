//
// CupScoringDisplay.swift
// LepreCON
//
// Presentation models for pending and completed cup scoring on the board.
//

import Foundation

/// One scoring color the player may confirm for a cup.
struct PendingScoreOptionDisplay: Equatable, Identifiable {
    let scoringColor: GemKind
    let displayName: String
    let isMatchingCupColor: Bool

    var id: GemKind { scoringColor }

    init(candidate: CupScoreCandidate) {
        scoringColor = candidate.scoringColor
        displayName = candidate.scoringColor.scoringDisplayName
        isMatchingCupColor = candidate.isMatchingCupColor
    }
}

/// Scoring labels and actions for one cup on the board.
struct CupScoringDisplay: Equatable {
    let pendingOptions: [PendingScoreOptionDisplay]
    /// Set when the cup is completed, e.g. "Scored Blue".
    let completedCaption: String?

    static let none = CupScoringDisplay(pendingOptions: [], completedCaption: nil)

    var hasPendingOptions: Bool { !pendingOptions.isEmpty }
    var isCompleted: Bool { completedCaption != nil }

    /// Short summary for a caption under the lane, e.g. "Can score: Red / Blue".
    var pendingSummary: String? {
        guard hasPendingOptions else { return nil }
        let names = pendingOptions.map(\.displayName).joined(separator: " / ")
        return "Can score: \(names)"
    }
}

/// One row in the scoring controls list (a cup with pending options).
struct CupScoringRowDisplay: Equatable, Identifiable {
    let cupIndex: Int
    let cupLabel: String
    let pendingOptions: [PendingScoreOptionDisplay]

    var id: Int { cupIndex }
}

extension GemKind {
    /// User-facing rainbow color name for scoring controls.
    var scoringDisplayName: String {
        rawValue.capitalized
    }
}
