//
// GameRulesTests.swift
// LepreCONTests
//
// Unit tests for GameRules placeholder helpers.
//

import XCTest
@testable import LepreCON

final class GameRulesTests: XCTestCase {

    func testCanStartGameReturnsTrueWhenSetupAndHasPlayers() {
        let session = GameSession(phase: .setup, players: [Player(name: "Alex")])

        XCTAssertTrue(GameRules.canStartGame(session))
    }

    func testCanStartGameReturnsFalseWhenNoPlayers() {
        let session = GameSession(phase: .setup, players: [])

        XCTAssertFalse(GameRules.canStartGame(session))
    }

    func testIsGameOverReturnsTrueWhenPhaseIsFinished() {
        let session = GameSession(phase: .finished, players: [Player(name: "Alex")])

        XCTAssertTrue(GameRules.isGameOver(session))
    }

    func testCurrentPlayerReturnsCorrectPlayerWhenPlaying() {
        let first = Player(name: "Alex")
        let second = Player(name: "Sam")
        let session = GameSession(
            phase: .playing,
            players: [first, second],
            currentPlayerIndex: 1
        )

        XCTAssertEqual(GameRules.currentPlayer(in: session)?.id, second.id)
        XCTAssertEqual(GameRules.currentPlayer(in: session)?.name, "Sam")
    }

    func testCurrentPlayerReturnsNilWhenIndexIsInvalid() {
        let session = GameSession(
            phase: .playing,
            players: [Player(name: "Alex")],
            currentPlayerIndex: 3
        )

        XCTAssertNil(GameRules.currentPlayer(in: session))
    }
}
