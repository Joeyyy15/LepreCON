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

    func testMakeNewGameCreatesCups() {
        let session = factory.makeNewGame(playerNames: ["Alex"])

        XCTAssertFalse(session.cups.isEmpty)
        XCTAssertEqual(session.cups.count, CupColor.allCases.count + 1)
        XCTAssertTrue(session.cups.contains(where: \.isPotOfGold))
    }

    func testMakeNewGameCreatesGemsInBag() {
        let session = factory.makeNewGame(playerNames: ["Alex"])

        XCTAssertFalse(session.gemsInBag.isEmpty)
        // 5 per rainbow color (6) + 5 special kinds = 35
        XCTAssertEqual(session.gemsInBag.count, 35)
    }
}
