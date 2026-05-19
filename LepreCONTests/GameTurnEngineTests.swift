//
// GameTurnEngineTests.swift
// LepreCONTests
//
// Behavior-focused tests for turn drawing and gem placement.
//

import XCTest
@testable import LepreCON

final class GameTurnEngineTests: XCTestCase {

    // MARK: - Test helpers

    private func makePlayingSession(
        bag: [Gem] = [Gem(kind: .red), Gem(kind: .blue), Gem(kind: .green)],
        cupsEmpty: Bool = true
    ) -> GameSession {
        var session = GameSessionFactory().makeNewGame(playerNames: ["Alex"])
        session.phase = .playing
        session.gemsInBag = bag
        session.gemsInHand = []
        session.discardPile = []
        session.currentRoll = nil
        if cupsEmpty {
            for index in session.cups.indices {
                session.cups[index].gems = []
            }
        }
        return session
    }

    // MARK: - Drawing

    func testBeginTurnDrawsGemsFromBagIntoHand() {
    let red = Gem(kind: .red)
    let blue = Gem(kind: .blue)
    var session = makePlayingSession(bag: [red, blue, Gem(kind: .green)])

    let result = GameTurnEngine.beginTurn(session: &session, roll: 2)

    assertSuccess(result)
    XCTAssertEqual(session.gemsInHand.count, 2)
    XCTAssertEqual(session.gemsInHand.map(\.id), [red.id, blue.id])
    XCTAssertEqual(session.gemsInBag.count, 1)
    XCTAssertEqual(session.currentRoll, 2)
    XCTAssertEqual(session.nextPlacementCupIndex, GameSetup.firstPlacementCupIndex)
  }

  func testBeginTurnDoesNotDrawMoreGemsThanAvailableInBag() {
    var session = makePlayingSession(bag: [Gem(kind: .red)])

    let result = GameTurnEngine.beginTurn(session: &session, roll: 5)

    assertSuccess(result)
    XCTAssertEqual(session.gemsInHand.count, 1)
    XCTAssertTrue(session.gemsInBag.isEmpty)
  }

  func testDrawGemsIntoHandRemovesFromBagAndAppendsToHand() {
    var session = makePlayingSession(bag: [Gem(kind: .gold), Gem(kind: .pink)])

    GameTurnEngine.drawGemsIntoHand(session: &session, count: 2)

    XCTAssertEqual(session.gemsInHand.count, 2)
    XCTAssertTrue(session.gemsInBag.isEmpty)
  }

  // MARK: - Placement

  func testPlaceGemInCurrentCupRemovesGemFromHand() {
    let gem = Gem(kind: .yellow)
    var session = makePlayingSession(bag: [])
    session.gemsInHand = [gem]
    session.currentRoll = 3
    session.nextPlacementCupIndex = GameSetup.firstPlacementCupIndex

    let result = GameTurnEngine.placeGemInCurrentCup(session: &session, gemID: gem.id)

    assertSuccess(result)
    XCTAssertTrue(session.gemsInHand.isEmpty)
  }

  func testPlaceGemInCurrentCupAddsGemToExpectedCup() {
    let gem = Gem(kind: .yellow)
    let placementIndex = GameSetup.firstPlacementCupIndex
    var session = makePlayingSession(bag: [])
    session.gemsInHand = [gem]
    session.currentRoll = 1
    session.nextPlacementCupIndex = placementIndex

    _ = GameTurnEngine.placeGemInCurrentCup(session: &session, gemID: gem.id)

    XCTAssertTrue(session.cups[placementIndex].gems.contains(where: { $0.id == gem.id }))
  }

  func testPlaceGemInCurrentCupAdvancesToNextCup() {
    let first = Gem(kind: .red)
    let second = Gem(kind: .blue)
    let startIndex = GameSetup.firstPlacementCupIndex
    var session = makePlayingSession(bag: [])
    session.gemsInHand = [first, second]
    session.currentRoll = 2
    session.nextPlacementCupIndex = startIndex

    _ = GameTurnEngine.placeGemInCurrentCup(session: &session, gemID: first.id)

    let expectedNext = (startIndex + 1) % session.cups.count
    XCTAssertEqual(session.nextPlacementCupIndex, expectedNext)
  }

  func testPlacementWrapsFromLastCupToFirstCup() {
    let gem = Gem(kind: .clear)
    var session = makePlayingSession(bag: [])
    session.gemsInHand = [gem]
    session.currentRoll = 1
    session.nextPlacementCupIndex = session.cups.count - 1

    _ = GameTurnEngine.placeGemInCurrentCup(session: &session, gemID: gem.id)

    XCTAssertEqual(session.nextPlacementCupIndex, 0)
  }

  func testPlaceGemInDiscardAddsToDiscardPileWithoutAdvancingCup() {
    let gem = Gem(kind: .pink)
    let cupIndexBefore = 3
    var session = makePlayingSession(bag: [])
    session.gemsInHand = [gem]
    session.currentRoll = 1
    session.nextPlacementCupIndex = cupIndexBefore

    let result = GameTurnEngine.placeGemInDiscard(session: &session, gemID: gem.id)

    assertSuccess(result)
    XCTAssertEqual(session.discardPile.count, 1)
    XCTAssertEqual(session.discardPile.first?.id, gem.id)
    XCTAssertEqual(session.nextPlacementCupIndex, cupIndexBefore)
  }

  func testFirstPlacementCupIndexIsOneLeftOfFirstWhiteCup() {
    XCTAssertEqual(GameSetup.firstPlacementCupIndex, 10)
    XCTAssertEqual(GameSetup.physicalCupLayout[0], .white)
    XCTAssertEqual(GameSetup.physicalCupLayout[10], .black)
  }

    private func assertSuccess(_ result: Result<Void, GameTurnError>, file: StaticString = #file, line: UInt = #line) {
        if case .failure(let error) = result {
            XCTFail("Expected success, got \(error)", file: file, line: line)
        }
    }
}
