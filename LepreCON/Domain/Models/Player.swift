//
// Player.swift
// LepreCON
//
// Represents a person playing a game session. Used for turn order and display names.
//

import Foundation

/// A player in a LepreCON game.
struct Player: Identifiable, Equatable, Codable {
    let id: UUID
    var name: String

    init(id: UUID = UUID(), name: String) {
        self.id = id
        self.name = name
    }
}
