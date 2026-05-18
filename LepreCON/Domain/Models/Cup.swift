//
// Cup.swift
// LepreCON
//
// Represents a cup on the board that holds gems. Cups are arranged in a circle;
// one cup may be the Pot of Gold, and others may match a rainbow color.
//

import Foundation

/// Which rainbow color a cup is associated with, if any.
enum CupColor: String, CaseIterable, Codable {
    case red
    case orange
    case yellow
    case green
    case blue
    case purple
    case white
}

/// A cup that can hold gems during a game.
struct Cup: Identifiable, Equatable, Codable {
    let id: UUID
    /// When set, scoring in this cup can double that color (rules-dependent).
    let color: CupColor?
    /// True for the Pot of Gold cup.
    let isPotOfGold: Bool
    /// Gems currently in this cup.
    var gems: [Gem]

    init(
        id: UUID = UUID(),
        color: CupColor? = nil,
        isPotOfGold: Bool = false,
        gems: [Gem] = []
    ) {
        self.id = id
        self.color = color
        self.isPotOfGold = isPotOfGold
        self.gems = gems
    }
}
