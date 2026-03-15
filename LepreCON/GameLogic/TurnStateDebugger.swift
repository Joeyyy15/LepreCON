import Foundation

/// Temporary helper for inspecting an in-progress turn.
enum TurnStateDebugger {
    
    /// Returns a readable summary of the current turn state.
    static func summary(for turn: TurnState) -> String {
        let available = turn.availableGems.map { $0.rawValue }.joined(separator: ", ")
        
        return """
        Available gems: [\(available)]
        Current cup index: \(turn.currentCupIndex)
        Turn complete: \(turn.isComplete)
        """
    }
}
