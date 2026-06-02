//
// GameSessionFactoryTests.swift
// LepreCONTests
//
// Unit tests for new-game setup via GameSessionFactory.
//

import XCTest
@testable import LepreCON

final class GameSessionFactoryTests: XCTestCase {

    private let factory = GameSessionFactory()

    func testMakeNewGameCreatesCorrectNumberOfPlayers() {
        let session = factory.makeNewGame(playerNames: ["Alex", "Sam", "Jordan"])

        XCTAssertEqual(session.players.count, 3)
        XCTAssertEqual(session.players.map(\.name), ["Alex", "Sam", "Jordan"])
    }

    func testMakeNewGameStartsInSetupPhase() {
        let session = factory.makeNewGame(playerNames: ["Alex"])

        XCTAssertEqual(session.phase, .setup)
    }

    func testMakeNewGameStartsWithCurrentPlayerIndexZero() {
        let session = factory.makeNewGame(playerNames: ["Alex", "Sam"])

        XCTAssertEqual(session.currentPlayerIndex, 0)
    }

    func testMakeNewGameCreatesElevenCups() {
        let session = factory.makeNewGame(playerNames: ["Alex"])

        XCTAssertEqual(session.cups.count, 11)
    }

    func testMakeNewGameBoardLayoutMatchesRulebookOrder() {
        let session = factory.makeNewGame(playerNames: ["Alex"])

        XCTAssertEqual(session.cups[0].color, .white)
        XCTAssertEqual(session.cups[1].color, .white)
        XCTAssertEqual(session.cups[2].color, .red)
        XCTAssertEqual(session.cups[3].color, .orange)
        XCTAssertEqual(session.cups[4].color, .yellow)
        XCTAssertEqual(session.cups[5].color, .green)
        XCTAssertEqual(session.cups[6].color, .blue)
        XCTAssertEqual(session.cups[7].color, .purple)
        XCTAssertEqual(session.cups[8].color, .white)
        XCTAssertEqual(session.cups[9].color, .white)
        XCTAssertTrue(session.cups[10].isPotOfGold)
    }

    func testMakeNewGamePlacesExactlyOneGemInEachCup() {
        let session = factory.makeNewGame(playerNames: ["Alex"])

        for cup in session.cups {
            XCTAssertEqual(cup.gems.count, 1)
        }
    }

    func testMakeNewGameDoesNotPlaceBlackGemsInCups() {
        let session = factory.makeNewGame(playerNames: ["Alex"])

        let gemsInCups = session.cups.flatMap(\.gems)
        XCTAssertFalse(gemsInCups.contains(where: { $0.kind == .black }))
    }

    func testMakeNewGameKeepsAllBlackGemsInBag() {
        let session = factory.makeNewGame(playerNames: ["Alex"])

        let blackGemsInBag = session.gemsInBag.filter { $0.kind == .black }
        XCTAssertEqual(blackGemsInBag.count, 3)
    }

    func testMakeNewGameHasNinetyThreeGemsTotalAcrossCupsAndBag() {
        let session = factory.makeNewGame(playerNames: ["Alex"])

        let gemsInCups = session.cups.flatMap(\.gems)
        let totalGems = gemsInCups.count + session.gemsInBag.count

        XCTAssertEqual(totalGems, GameSetup.totalGemCount)
        XCTAssertEqual(totalGems, 93)
    }

    func testMakeNewGameLeavesRemainingGemsInBag() {
        let session = factory.makeNewGame(playerNames: ["Alex"])

        XCTAssertEqual(session.gemsInBag.count, 82)
    }

    func testFirstPlacementCupIndexIsFirstCloudAfterPot() {
        XCTAssertEqual(GameSetup.firstPlacementCupIndex, 0)
        XCTAssertEqual(GameSetup.potOfGoldCupIndex, 10)
    }

    func testMakeNewGameAssignsUnicornToValidCup() {
        let session = factory.makeNewGame(playerNames: ["Alex"])

        guard let unicornCupIndex = session.unicornCupIndex else {
            XCTFail("Expected unicornCupIndex to be assigned during setup")
            return
        }

        XCTAssertTrue(GameSetup.validUnicornCupIndices(cups: session.cups).contains(unicornCupIndex))
        XCTAssertNotEqual(unicornCupIndex, GameSetup.potOfGoldCupIndex)
        XCTAssertFalse(session.cups[unicornCupIndex].isPotOfGold)
        XCTAssertEqual(session.unicornCupID, session.cups[unicornCupIndex].id)
    }
}
