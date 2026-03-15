import Foundation

/// The different cup locations on the board.
///
/// This includes:
/// - rainbow color cups
/// - three white cups
/// - the pot of gold
/// - the discard cup
enum CupType: String, CaseIterable {
    case red
    case orange
    case yellow
    case green
    case blue
    case purple
    case whiteOne
    case whiteTwo
    case whiteThree
    case potOfGold
    case discard
}

/// Represents a single cup on the board.
///
/// Each cup has:
/// - a stable id for tracking position
/// - a type that defines what kind of cup it is
/// - a list of gems currently inside it
struct Cup: Identifiable {
    let id: Int
    let type: CupType
    var gems: [GemType]
}
