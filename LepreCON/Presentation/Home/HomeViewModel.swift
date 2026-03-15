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

final class HomeViewModel: ObservableObject {
    // MARK: - State

    /// Selected play mode for the Online / Local toggle.
    @Published var playMode: PlayMode = .local

    // MARK: - Top Bar Actions (placeholder)

    func profileTapped() {
        // Placeholder: navigate to profile or show profile sheet.
    }

    func settingsTapped() {
        // Placeholder: navigate to settings or show settings sheet.
    }

    // MARK: - Menu Actions (placeholder)

    func theStableTapped() {
        // Placeholder: open The Stable screen.
    }

    func howToPlayTapped() {
        // Placeholder: open How To Play / rules.
    }

    func recordBookTapped() {
        // Placeholder: open Record Book.
    }

    func difficultyTapped() {
        // Placeholder: open Difficulty selection.
    }

    func customizationTapped() {
        // Placeholder: open Customization.
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
}

