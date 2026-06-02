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

    // MARK: - Score confirmation

    @MainActor
    private func makeViewModelWithPendingScore(
        cupIndex: Int,
        gemKinds: [GemKind]
    ) -> GameViewModel {
        var session = GameSessionFactory().makeNewGame(playerNames: ["Player 1"])
        session.phase = .playing
        for index in session.cups.indices {
            session.cups[index].gems = []
        }
        session.cups[cupIndex].gems = gemKinds.map { Gem(kind: $0) }
        session.isTurnPlacementComplete = true
        PendingScoreDetector.refreshPendingScoreChoices(in: &session)
        return GameViewModel(session: session)
    }

    func testConfirmScoreThroughViewModelCompletesCup() async {
        await MainActor.run {
            let viewModel = makeViewModelWithPendingScore(cupIndex: 2, gemKinds: Array(repeating: .blue, count: 5))

            let result = viewModel.confirmScore(cupIndex: 2, scoringColor: .blue)

            switch result {
            case .success: break
            case .failure(let error):
                XCTFail("Expected success, got \(error)")
            }

            XCTAssertTrue(viewModel.session.cups[2].isCompleted)
            XCTAssertEqual(viewModel.session.cups[2].completion?.scoredColor, .blue)
            XCTAssertEqual(
                viewModel.boardDisplayState.rainbowLanes.first { $0.cupIndex == 2 }?.scoring.completedCaption,
                "Scored Blue"
            )
        }
    }

    func testConfirmScoreMovesGoldToPotOfGold() async {
        await MainActor.run {
            let viewModel = makeViewModelWithPendingScore(
                cupIndex: 2,
                gemKinds: Array(repeating: .red, count: 5) + [.gold]
            )
            let potIndex = GameSetup.potOfGoldCupIndex
            let potGoldBefore = viewModel.session.cups[potIndex].gems.filter { $0.kind == .gold }.count

            _ = viewModel.confirmScore(cupIndex: 2, scoringColor: .red)

            XCTAssertEqual(
                viewModel.session.cups[potIndex].gems.filter { $0.kind == .gold }.count,
                potGoldBefore + 1
            )
        }
    }

    func testConfirmScoreClearsScoredCupGems() async {
        await MainActor.run {
            let viewModel = makeViewModelWithPendingScore(cupIndex: 2, gemKinds: Array(repeating: .red, count: 5))

            _ = viewModel.confirmScore(cupIndex: 2, scoringColor: .red)

            XCTAssertTrue(viewModel.session.cups[2].gems.isEmpty)
        }
    }

    func testConfirmScoreRefreshesPendingDisplayState() async {
        await MainActor.run {
            var session = GameSessionFactory().makeNewGame(playerNames: ["Player 1"])
            session.phase = .playing
            for index in session.cups.indices {
                session.cups[index].gems = []
            }
            session.cups[2].gems = Array(repeating: Gem(kind: .red), count: 5)
            session.cups[6].gems = Array(repeating: Gem(kind: .blue), count: 5)
            session.isTurnPlacementComplete = true
            PendingScoreDetector.refreshPendingScoreChoices(in: &session)

            let viewModel = GameViewModel(session: session)

            XCTAssertEqual(viewModel.boardDisplayState.pendingScoringCups.count, 2)

            _ = viewModel.confirmScore(cupIndex: 2, scoringColor: .red)

            XCTAssertEqual(viewModel.boardDisplayState.pendingScoringCups.count, 1)
            XCTAssertEqual(viewModel.boardDisplayState.pendingScoringCups.first?.cupIndex, 6)
        }
    }

    func testMultipleCandidatesRequireExplicitColorChoice() async {
        await MainActor.run {
            let viewModel = makeViewModelWithPendingScore(
                cupIndex: 2,
                gemKinds: Array(repeating: .clear, count: 5)
            )

            XCTAssertGreaterThan(viewModel.pendingScoreChoicesForCup(cupIndex: 2).count, 1)

            _ = viewModel.confirmScore(cupIndex: 2, scoringColor: .purple)

            XCTAssertEqual(viewModel.session.cups[2].completion?.scoredColor, .purple)
            XCTAssertNotEqual(viewModel.session.cups[2].completion?.scoredColor, .red)
        }
    }

    func testCanRollD12IsFalseWhenPendingScoreChoicesExist() async {
        await MainActor.run {
            let viewModel = makeViewModelWithPendingScore(cupIndex: 2, gemKinds: Array(repeating: .red, count: 5))

            XCTAssertFalse(viewModel.canRollD12)
            XCTAssertTrue(viewModel.isInScoringChoicePhase)
        }
    }

    func testSkipScoringChoicesClearsPendingAndEnablesRoll() async {
        await MainActor.run {
            let viewModel = makeViewModelWithPendingScore(cupIndex: 2, gemKinds: Array(repeating: .red, count: 5))

            viewModel.skipScoringChoices()

            XCTAssertTrue(viewModel.session.pendingScoreChoices.isEmpty)
            XCTAssertTrue(viewModel.boardDisplayState.pendingScoringCups.isEmpty)
            XCTAssertFalse(viewModel.isInScoringChoicePhase)
            XCTAssertTrue(viewModel.canRollD12)
        }
    }

    func testConfirmingOneScoreKeepsRollDisabledWhenOtherPendingChoicesRemain() async {
        await MainActor.run {
            var session = GameSessionFactory().makeNewGame(playerNames: ["Player 1"])
            session.phase = .playing
            for index in session.cups.indices {
                session.cups[index].gems = []
            }
            session.cups[2].gems = Array(repeating: Gem(kind: .red), count: 5)
            session.cups[6].gems = Array(repeating: Gem(kind: .blue), count: 5)
            session.isTurnPlacementComplete = true
            PendingScoreDetector.refreshPendingScoreChoices(in: &session)

            let viewModel = GameViewModel(session: session)
            _ = viewModel.confirmScore(cupIndex: 2, scoringColor: .red)

            XCTAssertFalse(viewModel.canRollD12)
            XCTAssertTrue(viewModel.isInScoringChoicePhase)
        }
    }

    func testConfirmingLastPendingScoreEnablesRoll() async {
        await MainActor.run {
            let viewModel = makeViewModelWithPendingScore(cupIndex: 2, gemKinds: Array(repeating: .red, count: 5))

            _ = viewModel.confirmScore(cupIndex: 2, scoringColor: .red)

            XCTAssertTrue(viewModel.session.pendingScoreChoices.isEmpty)
            XCTAssertTrue(viewModel.canRollD12)
            XCTAssertFalse(viewModel.isInScoringChoicePhase)
        }
    }

    func testGameViewModelExposesFinalScoreResult() async {
        await MainActor.run {
            var session = GameSessionFactory().makeNewGame(playerNames: ["Player 1"])
            session.phase = .playing
            session.cups[6].completion = CupCompletion(
                scoredColor: .blue,
                wasMatchingCupColor: true,
                goodCount: 5,
                passCount: 0,
                blemishCount: 0,
                adjustedGoodCount: 5
            )

            let viewModel = GameViewModel(session: session)

            XCTAssertEqual(viewModel.finalScoreResult.colorPoints, 2)
            XCTAssertEqual(viewModel.finalScoreResult.completedColorScores.count, 1)
            XCTAssertFalse(viewModel.isGameComplete)
        }
    }

    func testFinalScoreDisplayUpdatesAfterConfirmingScore() async {
        await MainActor.run {
            let viewModel = makeViewModelWithPendingScore(cupIndex: 2, gemKinds: Array(repeating: .red, count: 5))

            XCTAssertEqual(viewModel.boardDisplayState.finalScore.completedColorCount, 0)
            XCTAssertEqual(viewModel.boardDisplayState.finalScore.colorPoints, 0)

            _ = viewModel.confirmScore(cupIndex: 2, scoringColor: .red)

            XCTAssertEqual(viewModel.boardDisplayState.finalScore.completedColorCount, 1)
            XCTAssertEqual(viewModel.boardDisplayState.finalScore.colorPoints, 2)
            XCTAssertTrue(viewModel.boardDisplayState.finalScore.missingColorNames.contains("Orange"))
        }
    }

    func testBeginTurnFailsWhilePendingScoreChoicesExist() async {
        await MainActor.run {
            var session = GameSessionFactory().makeNewGame(playerNames: ["Player 1"])
            session.phase = .playing
            for index in session.cups.indices {
                session.cups[index].gems = []
            }
            session.cups[2].gems = Array(repeating: Gem(kind: .red), count: 5)
            session.isTurnPlacementComplete = true
            session.gemsInBag = [Gem(kind: .green)]
            PendingScoreDetector.refreshPendingScoreChoices(in: &session)

            let viewModel = GameViewModel(session: session)

            let result = viewModel.beginTurn(roll: 1)

            switch result {
            case .success:
                XCTFail("Expected beginTurn to fail while pending score choices exist")
            case .failure(let error):
                XCTAssertEqual(error, .pendingScoreChoicesUnresolved)
            }
            XCTAssertFalse(viewModel.session.pendingScoreChoices.isEmpty)
        }
    }

}
