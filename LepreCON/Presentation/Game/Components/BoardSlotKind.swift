//
//  BoardSlotKind.swift
//  LepreCON
//
//  Describes the different visual gem containers on the gameplay board.
//

import Foundation

enum BoardSlotKind: Equatable {
    case pot
    case cloud(number: Int)
    case rainbowLane(color: RainbowLaneColor)
}

enum RainbowLaneColor: String, CaseIterable, Identifiable {
    case red
    case orange
    case yellow
    case green
    case blue
    case purple

    var id: String {
        rawValue
    }

    var gemAssetName: String {
        switch self {
        case .red:
            return "gem_red"
        case .orange:
            return "gem_orange"
        case .yellow:
            return "gem_yellow"
        case .green:
            return "gem_green"
        case .blue:
            return "gem_blue"
        case .purple:
            return "gem_purple"
        }
    }

    /// Asset catalog image for the lane background artwork (display only).
    var laneBackgroundAssetName: String {
        switch self {
        case .red:
            return "red_lane"
        case .orange:
            return "orange_lane"
        case .yellow:
            return "yellow_lane"
        case .green:
            return "green_lane"
        case .blue:
            return "blue_lane"
        case .purple:
            return "purple_lane"
        }
    }

    var displayName: String {
        rawValue.capitalized
    }
}
