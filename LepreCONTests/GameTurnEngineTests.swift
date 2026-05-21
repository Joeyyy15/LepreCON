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
        // Two gems means the first placement is not the final gem in hand.
        let firstGem = Gem(kind: .clear)
        let secondGem = Gem(kind: .gold)

        var session = makePlayingSession(bag: [])
        session.gemsInHand = [firstGem, secondGem]
        session.currentRoll = 2
        session.nextPlacementCupIndex = session.cups.count - 1

        _ = GameTurnEngine.placeGemInCurrentCup(session: &session, gemID: firstGem.id)

        // Non-final placements should keep moving clockwise and wrap back to index 0.
        XCTAssertEqual(session.nextPlacementCupIndex, 0)
    }

    // MARK: - Future discard rules (engine only; not a current player action)

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

    func testFirstPlacementCupIndexIsFirstCloudAfterPot() {
        XCTAssertEqual(GameSetup.firstPlacementCupIndex, 0)
        XCTAssertEqual(GameSetup.potOfGoldCupIndex, 10)
    }

    func testCanRollAgainAfterPlacementCompletes() {
        var session = makePlayingSession(
            bag: [
                Gem(kind: .red),
                Gem(kind: .green),
                Gem(kind: .blue)
            ]
        )
        session.cups[0].gems.removeAll()
        _ = GameTurnEngine.beginTurn(session: &session, roll: 1)

        let gemID = session.gemsInHand[0].id
        _ = GameTurnEngine.placeGemInCurrentCup(session: &session, gemID: gemID)

        XCTAssertTrue(session.isTurnPlacementComplete)
        XCTAssertFalse(GameTurnEngine.isTurnInProgress(in: session))

        let result = GameTurnEngine.beginTurn(session: &session, roll: 2)
        assertSuccess(result)
        XCTAssertFalse(session.isTurnPlacementComplete)
        XCTAssertEqual(session.gemsInHand.count, 2)
    }

    private func assertSuccess(_ result: Result<Void, GameTurnError>, file: StaticString = #file, line: UInt = #line) {
        if case .failure(let error) = result {
            XCTFail("Expected success, got \(error)", file: file, line: line)
        }
    }
    
    func testFinalGemPlacedInEmptyCupStopsPlacementWithoutAdvancing() {
        let gem = Gem(kind: .clear)

        var session = makePlayingSession(bag: [])
        session.gemsInHand = [gem]
        session.currentRoll = 1
        session.nextPlacementCupIndex = 0

        // Make sure the target cup is empty before placing the final gem.
        session.cups[0].gems.removeAll()

        _ = GameTurnEngine.placeGemInCurrentCup(session: &session, gemID: gem.id)

        // Final gem landed in an empty cup, so placement stops on that cup.
        XCTAssertEqual(session.nextPlacementCupIndex, 0)
        XCTAssertTrue(session.gemsInHand.isEmpty)
        XCTAssertEqual(session.cups[0].gems.count, 1)
    }
    
    func testFinalGemPlacedInNonEmptyCupScoopsCupIntoHand() {
        // One gem in hand means this placement is the final gem.
        let finalGem = Gem(kind: .clear)

        // This gem is already in the target cup before placement.
        // Because the cup is non-empty before the final gem lands, it should trigger a scoop.
        let existingCupGem = Gem(kind: .red)

        var session = makePlayingSession(bag: [])
        session.gemsInHand = [finalGem]
        session.currentRoll = 1
        session.nextPlacementCupIndex = 0

        // Put a gem in the target cup so the final placement lands in a non-empty cup.
        session.cups[0].gems = [existingCupGem]

        _ = GameTurnEngine.placeGemInCurrentCup(session: &session, gemID: finalGem.id)

        // The cup should be emptied because the final gem triggered the chain reaction scoop.
        XCTAssertTrue(session.cups[0].gems.isEmpty)

        // The player's hand should now contain both the original cup gem and the gem just placed.
        XCTAssertEqual(session.gemsInHand.count, 2)
        XCTAssertTrue(session.gemsInHand.contains(where: { $0.id == existingCupGem.id }))
        XCTAssertTrue(session.gemsInHand.contains(where: { $0.id == finalGem.id }))

        // After scooping, placement should advance to the next cup.
        XCTAssertEqual(session.nextPlacementCupIndex, 1)
    }
    
    func testNonFinalGemPlacedInNonEmptyCupDoesNotScoop() {
        // Two gems in hand means the first placement is not the final gem.
        let firstGem = Gem(kind: .clear)
        let secondGem = Gem(kind: .gold)

        // This gem is already in the target cup before placement.
        let existingCupGem = Gem(kind: .red)

        var session = makePlayingSession(bag: [])
        session.gemsInHand = [firstGem, secondGem]
        session.currentRoll = 2
        session.nextPlacementCupIndex = 0

        // Put a gem in the target cup so the cup is non-empty before placement.
        session.cups[0].gems = [existingCupGem]

        _ = GameTurnEngine.placeGemInCurrentCup(session: &session, gemID: firstGem.id)

        // Because this was not the final gem, the cup should not be scooped.
        XCTAssertEqual(session.cups[0].gems.count, 2)
        XCTAssertTrue(session.cups[0].gems.contains(where: { $0.id == existingCupGem.id }))
        XCTAssertTrue(session.cups[0].gems.contains(where: { $0.id == firstGem.id }))

        // The second gem should still be waiting in hand.
        XCTAssertEqual(session.gemsInHand.count, 1)
        XCTAssertEqual(session.gemsInHand.first?.id, secondGem.id)

        // Non-final placements should advance to the next cup.
        XCTAssertEqual(session.nextPlacementCupIndex, 1)
    }
    
    func testBeginTurnMarksPlacementIncomplete() {
        // A new turn should always start with placement still active.
        var session = makePlayingSession(bag: [
            Gem(kind: .red),
            Gem(kind: .blue)
        ])

        // Set this to true first so we can prove beginTurn resets it.
        session.isTurnPlacementComplete = true

        _ = GameTurnEngine.beginTurn(session: &session, roll: 2)

        XCTAssertFalse(session.isTurnPlacementComplete)
    }

    func testFinalGemPlacedInEmptyCupMarksPlacementComplete() {
        // One gem means this placement is the final gem in hand.
        let gem = Gem(kind: .clear)

        var session = makePlayingSession(bag: [])
        session.gemsInHand = [gem]
        session.currentRoll = 1
        session.nextPlacementCupIndex = 0
        session.isTurnPlacementComplete = false

        // Make the target cup empty so the final gem stops placement.
        session.cups[0].gems.removeAll()

        _ = GameTurnEngine.placeGemInCurrentCup(session: &session, gemID: gem.id)

        // Final gem landed in an empty cup, so placement is complete.
        XCTAssertTrue(session.isTurnPlacementComplete)
    }

    func testFinalGemPlacedInNonEmptyCupDoesNotMarkPlacementComplete() {
        // One gem means this placement is the final gem in hand.
        let finalGem = Gem(kind: .clear)

        // Existing gem makes the cup non-empty before placement,
        // which should trigger the chain reaction scoop instead of stopping.
        let existingCupGem = Gem(kind: .red)

        var session = makePlayingSession(bag: [])
        session.gemsInHand = [finalGem]
        session.currentRoll = 1
        session.nextPlacementCupIndex = 0
        session.isTurnPlacementComplete = false

        session.cups[0].gems = [existingCupGem]

        _ = GameTurnEngine.placeGemInCurrentCup(session: &session, gemID: finalGem.id)

        // Placement should continue because the final gem landed in a non-empty cup.
        XCTAssertFalse(session.isTurnPlacementComplete)
    }

    func testNonFinalGemPlacedInCupDoesNotMarkPlacementComplete() {
        // Two gems means the first placement is not the final gem.
        let firstGem = Gem(kind: .clear)
        let secondGem = Gem(kind: .gold)

        var session = makePlayingSession(bag: [])
        session.gemsInHand = [firstGem, secondGem]
        session.currentRoll = 2
        session.nextPlacementCupIndex = 0
        session.isTurnPlacementComplete = false

        // Make the target cup empty to prove non-final placement still keeps going.
        session.cups[0].gems.removeAll()

        _ = GameTurnEngine.placeGemInCurrentCup(session: &session, gemID: firstGem.id)

        // Since there is still another gem in hand, placement is not complete.
        XCTAssertFalse(session.isTurnPlacementComplete)
    }

    func testFinalGemPlacedInDiscardMarksPlacementComplete() {
        // Reserved for future magic/discard resolution — not manual player discard.
        let gem = Gem(kind: .pink)

        var session = makePlayingSession(bag: [])
        session.gemsInHand = [gem]
        session.currentRoll = 1
        session.isTurnPlacementComplete = false

        _ = GameTurnEngine.placeGemInDiscard(session: &session, gemID: gem.id)

        // Final gem landed in discard, so placement stops.
        // Magic will be handled later during resolution.
        XCTAssertTrue(session.isTurnPlacementComplete)
    }

    func testNonFinalGemPlacedInDiscardDoesNotMarkPlacementComplete() {
        // Reserved for future magic/discard resolution — not manual player discard.
        let firstGem = Gem(kind: .pink)
        let secondGem = Gem(kind: .blue)

        var session = makePlayingSession(bag: [])
        session.gemsInHand = [firstGem, secondGem]
        session.currentRoll = 2
        session.isTurnPlacementComplete = false

        _ = GameTurnEngine.placeGemInDiscard(session: &session, gemID: firstGem.id)

        // Since there is still another gem in hand, placement is not complete yet.
        XCTAssertFalse(session.isTurnPlacementComplete)
    }
}
