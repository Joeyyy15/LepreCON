//
// GameViewModel.swift
// LepreCON
//
// Owns the current game session and coordinates domain logic for the game screen.
// SwiftUI views read from here; they do not create GameSession values directly.
// Full turn/scoring rules are not implemented yet.
//

import Foundation
import Combine

@MainActor
final class GameViewModel: ObservableObject {

    /// The active game state (players, cups, bag, phase). Updated as the game progresses.
    @Published private(set) var session: GameSession

    private let factory: GameSessionFactory

    /// Display name for whoever's turn it is, when the game is in the playing phase.
    var currentPlayerName: String? {
        GameRules.currentPlayer(in: session)?.name
    }
    
    var phaseDisplayText: String {
        session.phase.rawValue.capitalized
    }
    
    /// True when the current game is allowed to end.
    var canEndGame: Bool {
        // Ask the Domain layer instead of duplicating game rules in the ViewModel.
        GameRules.canEndGame(session)
    }
    
    /// True when the current game is allowed to start.
    var canStartGame: Bool {
        // Ask the Domain layer instead of duplicating game rules in the ViewModel.
        GameRules.canStartGame(session)
    }

    /// Creates a new game in setup using default placeholder players until setup UI exists.
    init(
        factory: GameSessionFactory = GameSessionFactory(),
        playerNames: [String] = ["Player 1"]
    ) {
        self.factory = factory
        self.session = factory.makeNewGame(playerNames: playerNames)
    }

    /// Moves from setup to playing when domain rules allow it.
    func startGame() {
        guard GameRules.canStartGame(session) else { return }
        session.phase = .playing
    }
    
    /// Moves from playing to finished when domain rules allow it.
    func endGame() {
        // The Domain layer decides whether ending the game is allowed.
        guard GameRules.canEndGame(session) else { return }

        session.phase = .finished
    }
    
    /// Starts a gameplay turn using the rolled D12 value.
    ///
    /// The ViewModel does not decide turn rules itself.
    /// It delegates to GameTurnEngine so the Domain layer owns the gameplay logic.
    func beginTurn(roll: Int) -> Result<Void, GameTurnError> {
        GameTurnEngine.beginTurn(session: &session, roll: roll)
    }
}
