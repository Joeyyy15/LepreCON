import Foundation

/// Handles placing one chosen gem during an in-progress turn.
enum TurnPlacer {
    
    /// Places one selected gem from the turn's available gems into the current cup.
    ///
    /// - Parameters:
    ///   - gemIndex: The index of the chosen gem inside `turn.availableGems`
    ///   - turn: The in-progress turn state
    ///   - board: The game board being modified
    ///
    /// Current simplified version:
    /// - places the chosen gem into the current cup
    /// - removes that gem from the available gems
    /// - advances to the next cup
    /// - marks the turn complete if no gems remain
    static func placeChosenGem(
        at gemIndex: Int,
        turn: inout TurnState,
        on board: inout Board
    ) {
        guard !turn.isComplete else { return }
        guard gemIndex >= 0 && gemIndex < turn.availableGems.count else { return }
        guard board.cups.indices.contains(turn.currentCupIndex) else { return }
        
        let chosenGem = turn.availableGems.remove(at: gemIndex)
        board.cups[turn.currentCupIndex].gems.append(chosenGem)
        
        if turn.availableGems.isEmpty {
            turn.isComplete = true
        } else {
            turn.currentCupIndex = TurnManager.nextCupIndex(
                after: turn.currentCupIndex,
                on: board
            )
        }
    }
}
