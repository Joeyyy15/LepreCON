//
// UnicornAnimationScript.swift
// LepreCON
//
// Read-only presentation model for replaying recorded unicorn resolution steps.
//

import Foundation

/// One visual step in the unicorn resolution replay (derived from domain events).
enum UnicornAnimationStep: Equatable {
    /// White gem calmed the unicorn; hold at this cup.
    case calmAtCup(cupIndex: Int)
    /// Unicorn carries one gem from its current cup to the destination cup.
    case carryGemToCup(gemKind: GemKind, toCupIndex: Int)
}

/// Ordered unicorn animation derived from `TurnResolutionEvent` records.
struct UnicornAnimationScript: Equatable {
    let startCupIndex: Int
    let steps: [UnicornAnimationStep]
}

enum UnicornAnimationTiming {
    static let travelSeconds: Double = 0.55
    static let dropSeconds: Double = 0.35
    static let stepPauseSeconds: Double = 0.2
    static let calmHoldSeconds: Double = 0.7
    static let emptyExplosionHoldSeconds: Double = 0.45
}
