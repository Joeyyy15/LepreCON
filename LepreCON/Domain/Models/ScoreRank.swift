//
// ScoreRank.swift
// LepreCON
//
// Final score rank labels from the rulebook.
//

import Foundation

/// Player rank based on total final score.
enum ScoreRank: String, Equatable, Codable {
    case weeLad
    case trickster
    case fairy
    case luckNorris

    /// Rulebook label shown in the UI.
    var displayName: String {
        switch self {
        case .weeLad: return "Wee-lad"
        case .trickster: return "Trickster"
        case .fairy: return "Fairy"
        case .luckNorris: return "Luck Norris"
        }
    }

    /// Maps total points to a rank (0–6, 7–12, 13–18, 19+).
    static func from(totalPoints: Int) -> ScoreRank {
        switch totalPoints {
        case 0...6: return .weeLad
        case 7...12: return .trickster
        case 13...18: return .fairy
        default: return .luckNorris
        }
    }
}
