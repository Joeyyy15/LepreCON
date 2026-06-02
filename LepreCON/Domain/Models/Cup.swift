//
// Cup.swift
// LepreCON
//
// Represents a cup on the board that holds gems. Cups are arranged in a circle
// following the physical setup layout (see GameSetup.boardSlotLayout).
//

import Foundation

/// Board cup color. Each physical cup on the table has one of these colors.
enum CupColor: String, CaseIterable, Codable {
    case white
    case red
    case orange
    case yellow
    case green
    case blue
    case purple
    case black
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
    /// Set when this cup has scored. Completed cups stay visible but are skipped during placement.
    var completion: CupCompletion?

    /// True when this cup has scored and should be treated as removed for placement.
    var isCompleted: Bool { completion != nil }

    init(
        id: UUID = UUID(),
        color: CupColor? = nil,
        isPotOfGold: Bool = false,
        gems: [Gem] = [],
        completion: CupCompletion? = nil
    ) {
        self.id = id
        self.color = color
        self.isPotOfGold = isPotOfGold
        self.gems = gems
        self.completion = completion
    }
}
