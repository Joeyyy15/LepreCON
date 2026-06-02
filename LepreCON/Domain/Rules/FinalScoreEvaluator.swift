//
// FinalScoreEvaluator.swift
// LepreCON
//
// Computes final score from completed cups, Pot of Gold gold, and unicorn capture.
//

import Foundation

/// Evaluates the player’s final score from confirmed cup completions.
enum FinalScoreEvaluator {

    /// Builds the current final score snapshot from the session board state.
    static func evaluate(session: GameSession) -> FinalScoreResult {
        let bestColorScores = bestScoresByRainbowColor(from: session)
        let completedColorScores = ScoreEvaluator.rainbowScoringColors.compactMap { color -> CompletedColorScore? in
            bestColorScores[color]
        }

        let colorPoints = completedColorScores.reduce(0) { $0 + $1.points }
        let missingColors = ScoreEvaluator.rainbowScoringColors.filter { bestColorScores[$0] == nil }
        let isRainbowComplete = missingColors.isEmpty

        let goldCountInPot = goldCountInPotOfGold(session: session)
        let unicornCaptured = session.unicornCaptured

        let goldPoints = isRainbowComplete ? goldCountInPot : 0
        let unicornPoints = isRainbowComplete && unicornCaptured ? 3 : 0
        let totalPoints = colorPoints + goldPoints + unicornPoints
        let rank = ScoreRank.from(totalPoints: totalPoints)

        return FinalScoreResult(
            isRainbowComplete: isRainbowComplete,
            completedColorScores: completedColorScores,
            colorPoints: colorPoints,
            goldPoints: goldPoints,
            unicornPoints: unicornPoints,
            totalPoints: totalPoints,
            rank: rank,
            missingColors: missingColors,
            goldCountInPot: goldCountInPot,
            unicornCaptured: unicornCaptured
        )
    }

    // MARK: - Helpers

    /// For each rainbow color, keeps the highest point value from any completed cup.
    private static func bestScoresByRainbowColor(
        from session: GameSession
    ) -> [GemKind: CompletedColorScore] {
        var best: [GemKind: CompletedColorScore] = [:]

        for (cupIndex, cup) in session.cups.enumerated() {
            guard !cup.isPotOfGold, let completion = cup.completion else { continue }
            guard ScoreEvaluator.rainbowScoringColors.contains(completion.scoredColor) else { continue }

            let points = completion.wasMatchingCupColor ? 2 : 1
            let entry = CompletedColorScore(
                color: completion.scoredColor,
                points: points,
                wasMatchingCupColor: completion.wasMatchingCupColor,
                cupIndex: cupIndex
            )

            if let existing = best[completion.scoredColor], existing.points >= points {
                continue
            }
            best[completion.scoredColor] = entry
        }

        return best
    }

    private static func goldCountInPotOfGold(session: GameSession) -> Int {
        guard let potIndex = session.cups.firstIndex(where: { $0.isPotOfGold }) else {
            return 0
        }
        return session.cups[potIndex].gems.filter { $0.kind == .gold }.count
    }
}
