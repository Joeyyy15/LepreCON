//
// ScoreEvaluator.swift
// LepreCON
//
// Pure domain scoring evaluation for a single cup. Not wired into turn flow yet.
// Magic, unicorn, poop, and final score totals are handled elsewhere.
//

import Foundation

/// Evaluates whether a cup can score and for which rainbow colors.
enum ScoreEvaluator {

    /// The six rainbow colors that cups can score as.
    static let rainbowScoringColors: [GemKind] = [
        .red, .orange, .yellow, .green, .blue, .purple
    ]

    /// Evaluates every rainbow color and returns all valid scoring candidates.
    static func evaluate(cup: Cup) -> ScoringResult {
        guard !cup.isPotOfGold else {
            return ScoringResult(candidates: [])
        }

        let candidates = rainbowScoringColors.compactMap { color in
            evaluate(cup: cup, scoringColor: color)
        }

        return ScoringResult(candidates: candidates)
    }

    // MARK: - Private helpers

    private static func evaluate(cup: Cup, scoringColor: GemKind) -> CupScoreCandidate? {
        var goodCount = 0
        var passCount = 0
        var blemishCount = 0

        for gem in cup.gems {
            switch gem.kind {
            case scoringColor, .clear:
                goodCount += 1
            case .white, .gold:
                passCount += 1
            case .pink, .black:
                blemishCount += 1
            case .red, .orange, .yellow, .green, .blue, .purple:
                // Another rainbow color that is not the scoring color being tested.
                blemishCount += 1
            }
        }

        let adjustedGoodCount = goodCount - blemishCount
        guard adjustedGoodCount >= 5 else { return nil }

        return CupScoreCandidate(
            scoringColor: scoringColor,
            goodCount: goodCount,
            passCount: passCount,
            blemishCount: blemishCount,
            adjustedGoodCount: adjustedGoodCount,
            isMatchingCupColor: cup.color == scoringColor.cupColor
        )
    }
}

// MARK: - GemKind ↔ CupColor

private extension GemKind {
    /// Maps a rainbow gem kind to its board cup color for matching checks.
    var cupColor: CupColor? {
        switch self {
        case .red: return .red
        case .orange: return .orange
        case .yellow: return .yellow
        case .green: return .green
        case .blue: return .blue
        case .purple: return .purple
        default: return nil
        }
    }
}
