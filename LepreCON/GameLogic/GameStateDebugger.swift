import Foundation

/// Temporary helper for inspecting game state while building mechanics.
enum GameStateDebugger {
    
    /// Returns a readable summary of the board and bag count.
    static func summary(for state: GameState) -> String {
        var lines: [String] = []
        
        lines.append("Bag count: \(state.bag.count)")
        lines.append("Unicorn cup id: \(state.unicornCupID?.description ?? "nil")")
        lines.append("Completed colors: \(state.completedColors.map { $0.rawValue }.joined(separator: ", "))")
        lines.append("Cups:")
        
        for cup in state.board.cups {
            let gemList = cup.gems.map { $0.rawValue }.joined(separator: ", ")
            lines.append("- Cup \(cup.id) [\(cup.type.rawValue)]: [\(gemList)]")
        }
        
        return lines.joined(separator: "\n")
    }
}
