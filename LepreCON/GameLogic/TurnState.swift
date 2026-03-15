import Foundation

/// Represents the current in-progress turn before all drawn gems are placed.
struct TurnState {
    /// Gems drawn for this turn that the player can choose from.
    var availableGems: [GemType]
    
    /// The cup index where the next selected gem should be placed.
    var currentCupIndex: Int
    
    /// Whether the placement phase of the turn is finished.
    var isComplete: Bool
}
