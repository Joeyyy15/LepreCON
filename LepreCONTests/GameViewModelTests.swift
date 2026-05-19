//
//  GameViewModelTests.swift
//  LepreCONTests
//
//  Tests for GameViewModel connecting to the Domain layer.
//

import XCTest
@testable import LepreCON

@MainActor
final class GameViewModelTests: XCTestCase {
    
    func testGameViewModelStartsWithSetupSession() {
        // Arrange / Act
        let viewModel = GameViewModel(playerNames: ["Player 1"])

        // Assert
        XCTAssertEqual(viewModel.session.phase, .setup)
        XCTAssertEqual(viewModel.session.currentPlayerIndex, 0)
        XCTAssertEqual(viewModel.session.players.count, 1)
        XCTAssertEqual(viewModel.session.players.first?.name, "Player 1")
    }

    func testStartGameChangesPhaseToPlaying() {
        // Arrange
        let viewModel = GameViewModel(playerNames: ["Player 1"])

        // Act
        viewModel.startGame()

        // Assert
        XCTAssertEqual(viewModel.session.phase, .playing)
    }

    func testCurrentPlayerNameReturnsPlayerNameAfterGameStarts() {
        // Arrange
        let viewModel = GameViewModel(playerNames: ["Player 1"])

        // Act
        viewModel.startGame()

        // Assert
        XCTAssertEqual(viewModel.currentPlayerName, "Player 1")
    }

    func testCurrentPlayerNameIsNilBeforeGameStarts() {
        // Arrange / Act
        let viewModel = GameViewModel(playerNames: ["Player 1"])

        // Assert
        XCTAssertEqual(viewModel.session.phase, .setup)
        XCTAssertNil(viewModel.currentPlayerName)
    }
    
    func testEndGameChangesPhaseToFinished() {
        let viewModel = GameViewModel(playerNames: ["Player 1"])

        viewModel.startGame()
        viewModel.endGame()

        XCTAssertEqual(viewModel.session.phase, .finished)
    }
    
    func testCanEndGameIsFalseBeforeGameStarts() {
        // Create a new game that starts in the setup phase.
        let viewModel = GameViewModel(playerNames: ["Player 1"])

        // The game should not be allowed to end before it starts.
        XCTAssertFalse(viewModel.canEndGame)
    }
    
    func testCanEndGameIsTrueAfterGameStarts() {
        // Create a new game that starts in the setup phase.
        let viewModel = GameViewModel(playerNames: ["Player 1"])

        // Start the game so the phase changes to playing.
        viewModel.startGame()

        // Once the game is playing, it should be allowed to end.
        XCTAssertTrue(viewModel.canEndGame)
    }
    
    func testCanStartGameIsTrueBeforeGameStarts() {
        // Create a new game that starts in the setup phase.
        let viewModel = GameViewModel(playerNames: ["Player 1"])

        // A setup game should be allowed to start.
        XCTAssertTrue(viewModel.canStartGame)
    }

    func testCanStartGameIsFalseAfterGameStarts() {
        // Create a new game that starts in the setup phase.
        let viewModel = GameViewModel(playerNames: ["Player 1"])

        // Start the game so it moves into the playing phase.
        viewModel.startGame()

        // Once the game is already playing, it should not be allowed to start again.
        XCTAssertFalse(viewModel.canStartGame)
    }
}
