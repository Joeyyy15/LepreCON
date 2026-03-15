import Foundation

/// Handles bag-related game logic such as drawing gems.
enum BagManager {
    
    /// Draws up to `count` gems from the bag.
    ///
    /// - Parameters:
    ///   - count: Number of gems to draw.
    ///   - bag: The current gem bag, passed in as inout so it can be modified.
    /// - Returns: An array of drawn gems in draw order.
    ///
    /// If the bag has fewer than `count` gems left, this returns only the gems
    /// that are still available.
    static func drawGems(count: Int, from bag: inout [GemType]) -> [GemType] {
        var drawnGems: [GemType] = []
        
        for _ in 0..<count {
            guard !bag.isEmpty else { break }
            drawnGems.append(bag.removeFirst())
        }
        
        return drawnGems
    }
}

