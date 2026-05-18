//
// Gem.swift
// LepreCON
//
// Represents a single gem used during play (rainbow colors, gold, white, etc.).
// Gems are placed into cups or held in the draw bag.
//

import Foundation

/// The kind of gem in the game. Matches the physical gem types described in the rules.
enum GemKind: String, CaseIterable, Codable {
    case red
    case orange
    case yellow
    case green
    case blue
    case purple
    case white
    case gold
    case black   // "poop" in the rules
    case clear   // can count as any rainbow color when scoring
    case pink
}

/// A gem instance on the board or in the bag.
struct Gem: Identifiable, Equatable, Codable {
    let id: UUID
    let kind: GemKind

    init(id: UUID = UUID(), kind: GemKind) {
        self.id = id
        self.kind = kind
    }
}
