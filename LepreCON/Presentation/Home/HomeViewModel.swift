//
// HomeViewModel.swift
// LepreCON
//
// Holds Home screen state and placeholder actions for all buttons.
// No game logic here—only navigation/UI actions to be wired later.
//

import Foundation
import SwiftUI
import Combine

/// Play mode: online vs local. Used by the Home screen segmented control.
enum PlayMode: String, CaseIterable {
    case online = "Online"
    case local = "Local"
}

/// Destinations that can be presented from the Home screen. Used with `destination` state for sheet navigation.
enum HomeDestination: String, CaseIterable, Identifiable {
    case profile
    case settings
    case theStable
    case howToPlay
    case recordBook
    case difficulty
    case customization

    var id: String { rawValue }

    /// Display title for placeholder screens.
    var title: String {
        switch self {
        case .profile: return "Profile"
        case .settings: return "Settings"
        case .theStable: return "The Stable"
        case .howToPlay: return "How To Play"
        case .recordBook: return "Record Book"
        case .difficulty: return "Difficulty"
        case .customization: return "Customization"
        }
    }
}



final class HomeViewModel: ObservableObject {
    // MARK: - State

    /// Selected play mode for the Online / Local toggle.
    @Published var destination: HomeDestination?
    @Published var playMode: PlayMode = .local

    // MARK: - Top Bar Actions (placeholder)

    func profileTapped() {
        destination = .profile
    }

    func settingsTapped() {
        destination = .settings
    }

    // MARK: - Menu Actions (placeholder)

    func theStableTapped() {
        destination = .theStable
    }

    func howToPlayTapped() {
        destination = .howToPlay
    }

    func recordBookTapped() {
        destination = .recordBook
    }

    func difficultyTapped() {
        destination = .difficulty
    }

    func customizationTapped() {
        destination = .customization
    }

    // MARK: - Play Mode

    func setPlayMode(_ mode: PlayMode) {
        playMode = mode
        // Placeholder: apply online vs local configuration when game logic is added.
    }

    // MARK: - Primary Action (placeholder)

    func playTapped() {
        // Placeholder: start game; actual navigation is handled by RootView via onStartGame.
    }

    /// Clears the current destination (dismisses the presented sheet).
    func dismissDestination() {
        destination = nil
    }
}

