import Foundation

/// Represents the full current state of a LepreCON game.
struct GameState {
    /// All cups and their current gems.
    var board: Board
    
    /// Remaining gems that can still be drawn.
    var bag: [GemType]
    
    /// The id of the cup currently holding the unicorn.
    var unicornCupID: Int?
    
    /// Placeholder for a future magic system.
    var heldMagic: Int?
    
    /// Tracks rainbow colors that have already been completed.
    var completedColors: [GemType]
}
