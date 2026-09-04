//
// PlacementDestination.swift
// LepreCON
//
// Domain-owned next legal placement target during an active turn.
//

import Foundation

/// Where the next gem from hand must be placed.
enum PlacementDestination: Equatable, Codable {
    /// Place into the cup at this board index.
    case cup(index: Int)
    /// One gem must go to the discard pile after completing a full board rotation.
    case discard
}
