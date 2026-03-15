import Foundation

/// Represents the full circle of cups used in the game.
struct Board {
    var cups: [Cup]

    /// Creates the default board layout in a fixed order.
    ///
    /// This order matters because later turn logic will place gems
    /// clockwise through these cups.
    static func makeDefaultBoard() -> Board {
        Board(cups: [
            Cup(id: 0, type: .red, gems: []),
            Cup(id: 1, type: .orange, gems: []),
            Cup(id: 2, type: .yellow, gems: []),
            Cup(id: 3, type: .green, gems: []),
            Cup(id: 4, type: .blue, gems: []),
            Cup(id: 5, type: .purple, gems: []),
            Cup(id: 6, type: .whiteOne, gems: []),
            Cup(id: 7, type: .whiteTwo, gems: []),
            Cup(id: 8, type: .whiteThree, gems: []),
            Cup(id: 9, type: .potOfGold, gems: []),
            Cup(id: 10, type: .discard, gems: [])
        ])
    }
}
