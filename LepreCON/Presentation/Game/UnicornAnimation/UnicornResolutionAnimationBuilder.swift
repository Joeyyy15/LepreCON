//
// UnicornResolutionAnimationBuilder.swift
// LepreCON
//
// Builds a presentation-only animation script from recorded resolution events.
//

import Foundation

enum UnicornResolutionAnimationBuilder {

    /// Returns a script when unicorn resolution events are present; otherwise `nil`.
    static func script(from events: [TurnResolutionEvent]) -> UnicornAnimationScript? {
        var startCupIndex: Int?
        var steps: [UnicornAnimationStep] = []

        for event in events {
            switch event {
            case .unicornCalmed(let cupIndex):
                startCupIndex = cupIndex
                steps = [.calmAtCup(cupIndex: cupIndex)]
            case .unicornExplosionStarted(let fromCupIndex):
                if startCupIndex == nil {
                    startCupIndex = fromCupIndex
                }
            case .unicornExplosionStep(let gemKind, _, let toCupIndex):
                steps.append(.carryGemToCup(gemKind: gemKind, toCupIndex: toCupIndex))
            case .unicornMoved:
                break
            case .poopDiscardedCup, .poopResolved:
                break
            }
        }

        guard let startCupIndex else { return nil }
        return UnicornAnimationScript(startCupIndex: startCupIndex, steps: steps)
    }
}
