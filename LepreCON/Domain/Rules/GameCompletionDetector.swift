//
// GameCompletionDetector.swift
// LepreCON
//
// Detects when the rainbow is fully collected (all six colors scored).
//

import Foundation

/// Checks whether the game’s win condition is met.
enum GameCompletionDetector {

    /// True when every rainbow color has been scored at least once.
    static func isGameComplete(session: GameSession) -> Bool {
        FinalScoreEvaluator.evaluate(session: session).isRainbowComplete
    }
}
