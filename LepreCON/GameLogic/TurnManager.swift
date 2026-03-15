import Foundation

/// Handles turn-related board movement and placement helpers.
enum TurnManager {
    
    /// Returns the next cup index when moving clockwise around the board.
    ///
    /// This wraps back to the start when it reaches the end of the cup array.
    static func nextCupIndex(after currentIndex: Int, on board: Board) -> Int {
        guard !board.cups.isEmpty else { return 0 }
        return (currentIndex + 1) % board.cups.count
    }
    
    /// Places the given gems onto the board, one per cup, moving clockwise.
    ///
    /// Current simplified version:
    /// - starts at `startingIndex`
    /// - places one gem in each cup
    /// - moves clockwise after every placement
    /// - does not handle chain reactions yet
    /// - does not skip any cups yet
    static func placeGems(
        _ gems: [GemType],
        startingAt startingIndex: Int,
        on board: inout Board
    ) {
        guard !board.cups.isEmpty else { return }
        
        var currentIndex = startingIndex
        
        for gem in gems {
            board.cups[currentIndex].gems.append(gem)
            currentIndex = nextCupIndex(after: currentIndex, on: board)
        }
    }
}
