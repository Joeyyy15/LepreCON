//
// PendingWhiteGemDecision.swift
// LepreCON
//
// A paused white-gem / unicorn decision. Nothing is applied automatically —
// the player must choose the unicorn outcome and the cup/chain outcome.
//

import Foundation

/// Pending choice when the unicorn cup contains a white gem at resolution time.
struct PendingWhiteGemDecision: Equatable, Codable {
    /// Index into `GameSession.cups` for the unicorn cup that contains a white gem.
    let cupIndex: Int
}
