//
//  GameViewModelTests.swift
//  LepreCONTests
//
//  Tests for GameViewModel connecting to the Domain layer.
//

import XCTest
@testable import LepreCON

final class GameViewModelTests: XCTestCase {
    
    func testGameViewModelStartsWithSetupSession() async {
        await MainActor.run {
            // Arrange / Act
            let viewModel = GameViewModel(playerNames: ["Player 1"])

            // Assert
            XCTAssertEqual(viewModel.session.phase, .setup)
            XCTAssertEqual(viewModel.session.currentPlayerIndex, 0)
            XCTAssertEqual(viewModel.session.players.count, 1)
            XCTAssertEqual(viewModel.session.players.first?.name, "Player 1")
        }
    }

    func testStartGameChangesPhaseToPlaying() async {
        await MainActor.run {
            // Arrange
            let viewModel = GameViewModel(playerNames: ["Player 1"])

            // Act
            viewModel.startGame()

            // Assert
            XCTAssertEqual(viewModel.session.phase, .playing)
        }
    }

    func testCurrentPlayerNameReturnsPlayerNameAfterGameStarts() async {
        await MainActor.run {
            // Arrange
            let viewModel = GameViewModel(playerNames: ["Player 1"])

            // Act
            viewModel.startGame()

            // Assert
            XCTAssertEqual(viewModel.currentPlayerName, "Player 1")
        }
    }

    func testCurrentPlayerNameIsNilBeforeGameStarts() async {
        await MainActor.run {
            // Arrange / Act
            let viewModel = GameViewModel(playerNames: ["Player 1"])

            // Assert
            XCTAssertEqual(viewModel.session.phase, .setup)
            XCTAssertNil(viewModel.currentPlayerName)
        }
    }
    
    func testEndGameChangesPhaseToFinished() async {
        await MainActor.run {
            let viewModel = GameViewModel(playerNames: ["Player 1"])

            viewModel.startGame()
            viewModel.endGame()

            XCTAssertEqual(viewModel.session.phase, .finished)
        }
    }
    
    func testCanEndGameIsFalseBeforeGameStarts() async {
        await MainActor.run {
            // Create a new game that starts in the setup phase.
            let viewModel = GameViewModel(playerNames: ["Player 1"])

            // The game should not be allowed to end before it starts.
            XCTAssertFalse(viewModel.canEndGame)
        }
    }
    
    func testCanEndGameIsTrueAfterGameStarts() async {
        await MainActor.run {
            // Create a new game that starts in the setup phase.
            let viewModel = GameViewModel(playerNames: ["Player 1"])

            // Start the game so the phase changes to playing.
            viewModel.startGame()

            // Once the game is playing, it should be allowed to end.
            XCTAssertTrue(viewModel.canEndGame)
        }
    }
    
    func testCanStartGameIsTrueBeforeGameStarts() async {
        await MainActor.run {
            // Create a new game that starts in the setup phase.
            let viewModel = GameViewModel(playerNames: ["Player 1"])

            // A setup game should be allowed to start.
            XCTAssertTrue(viewModel.canStartGame)
        }
    }

    func testCanStartGameIsFalseAfterGameStarts() async {
        await MainActor.run {
            let viewModel = GameViewModel(playerNames: ["Player 1"])
            viewModel.startGame()

            XCTAssertFalse(viewModel.canStartGame)
        }
    }
    
    func testBeginTurnDrawsRolledNumberOfGemsIntoHand() async {
        await MainActor.run {
            // Create a game and move it into the playing phase.
            let viewModel = GameViewModel(playerNames: ["Player 1"])
            viewModel.startGame()

            let startingBagCount = viewModel.session.gemsInBag.count

            // Begin a turn with a roll of 3.
            let result = viewModel.beginTurn(roll: 3)

            // Result<Void, GameTurnError> cannot be compared directly with XCTAssertEqual,
            // so we switch on the result and fail only if it returns an error.
            switch result {
            case .success:
                break
            case .failure(let error):
                XCTFail("Expected beginTurn to succeed, but got \(error)")
            }

            XCTAssertEqual(viewModel.session.gemsInHand.count, 3)
            XCTAssertEqual(viewModel.session.gemsInBag.count, startingBagCount - 3)
        }
    }

    func testBeginTurnStoresCurrentRoll() async {
        await MainActor.run {
            // Create a game and move it into the playing phase.
            let viewModel = GameViewModel(playerNames: ["Player 1"])
            viewModel.startGame()

            _ = viewModel.beginTurn(roll: 4)

            XCTAssertEqual(viewModel.session.currentRoll, 4)
        }
    }

    func testBeginTurnFailsBeforeGameStarts() async {
        await MainActor.run {
            // The game starts in setup, so turns should not begin yet.
            let viewModel = GameViewModel(playerNames: ["Player 1"])

            let result = viewModel.beginTurn(roll: 3)

            // Since the game is not playing yet, the Domain engine should reject the turn.
            switch result {
            case .success:
                XCTFail("Expected beginTurn to fail before the game starts.")
            case .failure(let error):
                XCTAssertEqual(error, .gameNotPlaying)
            }

            XCTAssertNil(viewModel.session.currentRoll)
            XCTAssertTrue(viewModel.session.gemsInHand.isEmpty)
        }
    }
    
    func testPlaceGemInCurrentCupMovesGemFromHandToCup() async {
        await MainActor.run {
            // Create a game, start it, and begin a turn so the hand has gems.
            let viewModel = GameViewModel(playerNames: ["Player 1"])
            viewModel.startGame()
            _ = viewModel.beginTurn(roll: 2)

            guard let gem = viewModel.session.gemsInHand.first else {
                XCTFail("Expected a gem in hand after beginning a turn.")
                return
            }

            let cupIndex = viewModel.session.nextPlacementCupIndex
            let startingHandCount = viewModel.session.gemsInHand.count
            let startingCupCount = viewModel.session.cups[cupIndex].gems.count

            let result = viewModel.placeGemInCurrentCup(gemID: gem.id)

            switch result {
            case .success:
                break
            case .failure(let error):
                XCTFail("Expected placement to succeed, but got \(error)")
            }

            XCTAssertEqual(viewModel.session.gemsInHand.count, startingHandCount - 1)
            XCTAssertEqual(viewModel.session.cups[cupIndex].gems.count, startingCupCount + 1)
            XCTAssertTrue(viewModel.session.cups[cupIndex].gems.contains(where: { $0.id == gem.id }))
        }
    }

    func testPlaceGemInCurrentCupDoesNotAddToDiscardPile() async {
        await MainActor.run {
            let viewModel = GameViewModel(playerNames: ["Player 1"])
            viewModel.startGame()
            _ = viewModel.beginTurn(roll: 2)

            guard let gem = viewModel.session.gemsInHand.first else {
                XCTFail("Expected a gem in hand after beginning a turn.")
                return
            }

            let discardCountBefore = viewModel.session.discardPile.count
            _ = viewModel.placeGemInCurrentCup(gemID: gem.id)

            XCTAssertEqual(viewModel.session.discardPile.count, discardCountBefore)
        }
    }

    func testPlacementCompletesAfterFinalGemInEmptyCup() async {
        await MainActor.run {
            var session = GameSessionFactory().makeNewGame(playerNames: ["Player 1"])
            session.phase = .playing
            session.gemsInBag = []
            session.gemsInHand = [Gem(kind: .red)]
            session.currentRoll = 1
            session.nextPlacementCupIndex = GameSetup.firstPlacementCupIndex
            session.cups[0].gems = []

            let viewModel = GameViewModel(session: session)

            guard let gem = viewModel.session.gemsInHand.first else {
                XCTFail("Expected gem in hand")
                return
            }

            _ = viewModel.placeGemInCurrentCup(gemID: gem.id)

            XCTAssertTrue(viewModel.session.isTurnPlacementComplete)
            XCTAssertTrue(viewModel.session.gemsInHand.isEmpty)
            XCTAssertTrue(viewModel.canRollD12)
        }
    }

}
