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

    func testMakeNewGameCupsAreInPhysicalLayoutOrder() {
        let session = factory.makeNewGame(playerNames: ["Alex"])
        let cupColors = session.cups.compactMap(\.color)

        XCTAssertEqual(cupColors, GameSetup.physicalCupLayout)
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

        // 93 total gems minus 11 placed in cups during setup
        XCTAssertEqual(session.gemsInBag.count, 82)
    }
}
