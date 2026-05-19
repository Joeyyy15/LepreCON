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
}
