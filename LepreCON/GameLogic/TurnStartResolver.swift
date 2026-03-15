import Foundation

/// Determines where turn placement starts on the board.
enum TurnStartResolver {
    
    /// Returns the index of the cup where placement should begin.
    ///
    /// Current rule:
    /// placement starts one cup to the left of the pot of gold.
    ///
    /// Since the board is stored in clockwise order, "left of the pot of gold"
    /// means the cup immediately before it in the array, wrapping if needed.
    static func startingCupIndex(on board: Board) -> Int? {
        guard let potOfGoldIndex = board.cups.firstIndex(where: { $0.type == .potOfGold }) else {
            return nil
        }
        
        if potOfGoldIndex == 0 {
            return board.cups.count - 1
        }
        
        return potOfGoldIndex - 1
    }
}
