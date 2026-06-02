//
// Gem.swift
// LepreCON
//
// Represents a single gem used during play (rainbow colors, gold, white, etc.).
// Gems are placed into cups or held in the draw bag.
//

import Foundation

/// The kind of gem in the game. Matches the physical gem types described in the rules.
///
/// **White and clear are different gems.** Do not treat them as the same type.
/// - **White:** does not hold color; can stop chain reactions and calm the unicorn;
///   scoring treats white as a pass (not a blemish). See rulebook for full behavior.
/// - **Clear:** becomes the color of choice; holds color and affects color piles;
///   scoring can count clear as the chosen color. See rulebook for full behavior.
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
    case clear
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
