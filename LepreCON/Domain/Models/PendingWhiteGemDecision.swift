//
// PendingWhiteGemDecision.swift
// LepreCON
//
// Two independent white-gem pauses. Nothing is applied automatically —
// the player must resolve the active context.
//

import Foundation

/// Pending white-gem choice owned by `GameSession`.
enum PendingWhiteGemDecision: Equatable, Codable {
    /// Final gem landed in a non-empty cup that contains white: scoop vs use-white-to-end-turn.
    case endPlacementChain(cupIndex: Int)
    /// End-of-turn unicorn cup contains white: explode vs use-white-to-calm.
    case stopUnicornSpread(cupIndex: Int)

    var cupIndex: Int {
        switch self {
        case .endPlacementChain(let cupIndex), .stopUnicornSpread(let cupIndex):
            return cupIndex
        }
    }
}
