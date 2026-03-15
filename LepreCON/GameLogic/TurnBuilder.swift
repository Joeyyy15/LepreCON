import Foundation

/// Builds an in-progress turn from the current game state.
enum TurnBuilder {
    
    /// Draws gems from the bag and creates a new turn state.
    ///
    /// - Parameters:
    ///   - drawCount: Number of gems to draw for the turn.
    ///   - state: The full current game state.
    /// - Returns: A TurnState if a starting cup can be found, otherwise nil.
    static func makeTurn(drawCount: Int, state: inout GameState) -> TurnState? {
        let drawnGems = BagManager.drawGems(count: drawCount, from: &state.bag)
        
        guard let startingIndex = TurnStartResolver.startingCupIndex(on: state.board) else {
            return nil
        }
        
        return TurnState(
            availableGems: drawnGems,
            currentCupIndex: startingIndex,
            isComplete: drawnGems.isEmpty
        )
    }
}
