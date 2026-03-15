import Foundation

/// Runs a simplified version of a turn.
///
/// Current version:
/// - draws gems from the bag
/// - finds the starting cup
/// - places gems clockwise on the board
///
/// This does not handle:
/// - chain reactions
/// - unicorn effects
/// - poop resolution
/// - scoring
/// - magic
enum SimpleTurnResolver {
    
    /// Executes one simplified turn using a draw count.
    static func runTurn(drawCount: Int, state: inout GameState) {
        let drawnGems = BagManager.drawGems(count: drawCount, from: &state.bag)
        
        guard let startingIndex = TurnStartResolver.startingCupIndex(on: state.board) else {
            return
        }
        
        TurnManager.placeGems(
            drawnGems,
            startingAt: startingIndex,
            on: &state.board
        )
    }
}
