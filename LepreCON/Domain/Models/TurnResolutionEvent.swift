//
// TurnResolutionEvent.swift
// LepreCON
//
// Lightweight record of what happened during end-of-turn resolution (unicorn, poop).
// Domain resolves immediately; UI reads these for temporary feedback.
//

import Foundation

/// One recorded step from unicorn or poop resolution at end of turn.
enum TurnResolutionEvent: Equatable, Codable {
    case unicornCalmed(cupIndex: Int)
    case unicornExplosionStarted(fromCupIndex: Int)
    case unicornExplosionStep(gemKind: GemKind, fromCupIndex: Int, toCupIndex: Int)
    /// Automatic Unicorn-spread discard after a full circuit of available cups.
    case unicornExplosionDiscarded(gemKind: GemKind)
    case unicornMoved(toCupIndex: Int)
    case poopDiscardedCup(cupIndex: Int, discardedGems: [Gem])
    case poopResolved
}
