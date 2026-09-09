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
        session.unicornCupIndex = 9
        session.unicornCupID = session.cups[9].id
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

    // MARK: - Rotation discard rules

    func testPlaceGemInDiscardAddsToDiscardPileWithoutAdvancingCup() {
    let gem = Gem(kind: .pink)
    let remaining = Gem(kind: .blue)
    var session = makePlayingSession(bag: [])
    session.gemsInHand = [gem, remaining]
    session.currentRoll = 2
    // Simulate a completed full rotation: next board resume cup is already set.
    session.nextPlacementCupIndex = 0
    session.placementsCompletedInCurrentRotation = session.cups.count

    let result = GameTurnEngine.placeGemInDiscard(session: &session, gemID: gem.id)

    assertSuccess(result)
    XCTAssertEqual(session.discardPile.count, 1)
    XCTAssertEqual(session.discardPile.first?.id, gem.id)
    XCTAssertEqual(session.nextPlacementCupIndex, 0)
    XCTAssertEqual(session.placementsCompletedInCurrentRotation, 0)
  }

    func testNormalGemCanBeDiscardedWhenDiscardIsRequired() {
        let gem = Gem(kind: .red)
        let remaining = Gem(kind: .blue)
        var session = makePlayingSession(bag: [])
        session.gemsInHand = [gem, remaining]
        session.currentRoll = 2
        session.nextPlacementCupIndex = 0
        session.placementsCompletedInCurrentRotation = session.cups.count

        XCTAssertTrue(GameTurnEngine.isDiscardRequired(in: session))
        XCTAssertTrue(GameTurnEngine.canDiscardGemKind(.red))
        XCTAssertTrue(GameTurnEngine.canSelectHandGemKind(.red, in: session))

        let result = GameTurnEngine.placeGemInDiscard(session: &session, gemID: gem.id)

        assertSuccess(result)
        XCTAssertEqual(session.discardPile.map(\.id), [gem.id])
        XCTAssertEqual(session.gemsInHand.map(\.id), [remaining.id])
        XCTAssertFalse(GameTurnEngine.isDiscardRequired(in: session))
    }

    func testBlackGemCannotBeDiscardedDuringRequiredRotationDiscard() {
        let poop = Gem(kind: .black)
        let red = Gem(kind: .red)
        let alreadyDiscarded = Gem(kind: .pink)
        var session = makePlayingSession(bag: [])
        session.gemsInHand = [poop, red]
        session.currentRoll = 2
        session.nextPlacementCupIndex = 3
        session.placementsCompletedInCurrentRotation = session.cups.count
        session.discardPile = [alreadyDiscarded]

        XCTAssertTrue(GameTurnEngine.isDiscardRequired(in: session))
        XCTAssertFalse(GameTurnEngine.canDiscardGemKind(.black))
        XCTAssertFalse(GameTurnEngine.canSelectHandGemKind(.black, in: session))
        XCTAssertTrue(GameTurnEngine.canSelectHandGemKind(.red, in: session))

        let handBefore = session.gemsInHand
        let pileBefore = session.discardPile
        let rotationBefore = session.placementsCompletedInCurrentRotation
        let destinationBefore = GameTurnEngine.currentPlacementDestination(in: session)
        let resumeCupBefore = session.nextPlacementCupIndex

        let rejected = GameTurnEngine.placeGemInDiscard(session: &session, gemID: poop.id)

        assertFailure(rejected, .cannotDiscardBlackGem)
        XCTAssertEqual(session.gemsInHand.map(\.id), handBefore.map(\.id))
        XCTAssertTrue(session.gemsInHand.contains(where: { $0.id == poop.id }))
        XCTAssertEqual(session.discardPile.map(\.id), pileBefore.map(\.id))
        XCTAssertEqual(session.placementsCompletedInCurrentRotation, rotationBefore)
        XCTAssertEqual(GameTurnEngine.currentPlacementDestination(in: session), destinationBefore)
        XCTAssertEqual(session.nextPlacementCupIndex, resumeCupBefore)
        XCTAssertTrue(GameTurnEngine.isDiscardRequired(in: session))
        XCTAssertFalse(session.isTurnPlacementComplete)

        let accepted = GameTurnEngine.placeGemInDiscard(session: &session, gemID: red.id)

        assertSuccess(accepted)
        XCTAssertEqual(session.discardPile.map(\.id), [alreadyDiscarded.id, red.id])
        XCTAssertEqual(session.gemsInHand.map(\.id), [poop.id])
        XCTAssertFalse(GameTurnEngine.isDiscardRequired(in: session))
        XCTAssertEqual(GameTurnEngine.currentPlacementDestination(in: session), .cup(index: resumeCupBefore))
        XCTAssertEqual(session.placementsCompletedInCurrentRotation, 0)
    }

    func testNonBlackGemKindsRemainLegalRotationDiscards() {
        let nonBlackKinds = GemKind.allCases.filter { $0 != .black }
        for kind in nonBlackKinds {
            XCTAssertTrue(
                GameTurnEngine.canDiscardGemKind(kind),
                "Expected \(kind) to remain a legal rotation discard"
            )
        }
        XCTAssertFalse(GameTurnEngine.canDiscardGemKind(.black))
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

    private func assertFailure(
        _ result: Result<Void, GameTurnError>,
        _ expected: GameTurnError,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        switch result {
        case .success:
            XCTFail("Expected failure \(expected), got success", file: file, line: line)
        case .failure(let error):
            XCTAssertEqual(error, expected, file: file, line: line)
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
        let gem = Gem(kind: .pink)

        var session = makePlayingSession(bag: [])
        session.gemsInHand = [gem]
        session.currentRoll = 1
        session.isTurnPlacementComplete = false
        session.nextPlacementCupIndex = 0
        session.placementsCompletedInCurrentRotation = session.cups.count

        _ = GameTurnEngine.placeGemInDiscard(session: &session, gemID: gem.id)

        // Final gem landed in discard, so placement stops.
        XCTAssertTrue(session.isTurnPlacementComplete)
    }

    func testNonFinalGemPlacedInDiscardDoesNotMarkPlacementComplete() {
        let firstGem = Gem(kind: .pink)
        let secondGem = Gem(kind: .blue)

        var session = makePlayingSession(bag: [])
        session.gemsInHand = [firstGem, secondGem]
        session.currentRoll = 2
        session.isTurnPlacementComplete = false
        session.nextPlacementCupIndex = 0
        session.placementsCompletedInCurrentRotation = session.cups.count

        _ = GameTurnEngine.placeGemInDiscard(session: &session, gemID: firstGem.id)

        // Since there is still another gem in hand, placement is not complete yet.
        XCTAssertFalse(session.isTurnPlacementComplete)
        XCTAssertEqual(GameTurnEngine.currentPlacementDestination(in: session), .cup(index: 0))
    }

    // MARK: - Completed cup placement skipping

    private func markCompleted(_ session: inout GameSession, cupIndex: Int, scoredColor: GemKind = .red) {
        session.cups[cupIndex].completion = CupCompletion(
            scoredColor: scoredColor,
            wasMatchingCupColor: false,
            goodCount: 5,
            passCount: 0,
            blemishCount: 0,
            adjustedGoodCount: 5
        )
    }

    func testBeginTurnSkipsCompletedFirstPlacementCup() {
        var session = makePlayingSession()
        markCompleted(&session, cupIndex: 0)

        _ = GameTurnEngine.beginTurn(session: &session, roll: 1)

        XCTAssertEqual(session.nextPlacementCupIndex, 1)
    }

    func testPlacementSkipsCompletedCup() {
        var session = makePlayingSession(bag: [])
        markCompleted(&session, cupIndex: 2) // red cup
        session.gemsInHand = [Gem(kind: .yellow), Gem(kind: .green)]
        session.currentRoll = 2
        session.nextPlacementCupIndex = 1 // cloud2

        _ = GameTurnEngine.placeGemInCurrentCup(session: &session, gemID: session.gemsInHand[0].id)

        // After cloud2, skip completed red (2) and land on orange (3).
        XCTAssertEqual(session.nextPlacementCupIndex, 3)
    }

    func testPlacementSkipsMultipleCompletedCupsInARow() {
        var session = makePlayingSession(bag: [])
        markCompleted(&session, cupIndex: 0)
        markCompleted(&session, cupIndex: 1)
        markCompleted(&session, cupIndex: 2)
        session.nextPlacementCupIndex = 2

        GameTurnEngine.advancePlacementIndex(session: &session)

        XCTAssertEqual(session.nextPlacementCupIndex, 3)
    }

    func testPlacementStillIncludesPotOfGoldWhenNotCompleted() {
        var session = makePlayingSession(bag: [])
        for index in 0..<GameSetup.potOfGoldCupIndex {
            markCompleted(&session, cupIndex: index)
        }
        session.nextPlacementCupIndex = 9 // cloud4

        GameTurnEngine.advancePlacementIndex(session: &session)

        XCTAssertEqual(session.nextPlacementCupIndex, GameSetup.potOfGoldCupIndex)
        XCTAssertTrue(session.cups[GameSetup.potOfGoldCupIndex].isPotOfGold)
        XCTAssertFalse(session.cups[GameSetup.potOfGoldCupIndex].isCompleted)
    }

    func testPlacementDoesNotInfiniteLoopWhenMostCupsAreCompleted() {
        var session = makePlayingSession(bag: [])
        for index in session.cups.indices where index != GameSetup.potOfGoldCupIndex {
            markCompleted(&session, cupIndex: index)
        }
        session.nextPlacementCupIndex = GameSetup.potOfGoldCupIndex

        GameTurnEngine.advancePlacementIndex(session: &session)

        // Only the pot remains — index stays on the pot instead of looping forever.
        XCTAssertEqual(session.nextPlacementCupIndex, GameSetup.potOfGoldCupIndex)
    }

    func testPlacementDoesNotInfiniteLoopWhenEveryCupIsCompleted() {
        var session = makePlayingSession(bag: [])
        for index in session.cups.indices {
            markCompleted(&session, cupIndex: index)
        }
        session.nextPlacementCupIndex = 4

        GameTurnEngine.advancePlacementIndex(session: &session)

        XCTAssertEqual(session.nextPlacementCupIndex, 4)
    }

    // MARK: - Full-rotation discard

    private func makeHand(count: Int, kind: GemKind = .red) -> [Gem] {
        (0..<count).map { _ in Gem(kind: kind) }
    }

    private func placeNextHandGem(session: inout GameSession) {
        guard let gemID = session.gemsInHand.first?.id else {
            XCTFail("Expected a gem in hand")
            return
        }
        let result = GameTurnEngine.placeGemInCurrentCup(session: &session, gemID: gemID)
        assertSuccess(result)
    }

    private func discardFirstHandGem(session: inout GameSession) {
        guard let gemID = session.gemsInHand.first?.id else {
            XCTFail("Expected a gem in hand")
            return
        }
        let result = GameTurnEngine.placeGemInDiscard(session: &session, gemID: gemID)
        assertSuccess(result)
    }

    func testDestinationRemainsCupBeforeFullRotation() {
        var session = makePlayingSession(bag: [])
        session.gemsInHand = makeHand(count: 5)
        session.currentRoll = 5
        session.nextPlacementCupIndex = 0
        session.placementsCompletedInCurrentRotation = 0

        placeNextHandGem(session: &session)

        XCTAssertEqual(GameTurnEngine.currentPlacementDestination(in: session), .cup(index: 1))
        XCTAssertFalse(GameTurnEngine.isDiscardRequired(in: session))
        let earlyDiscard = GameTurnEngine.placeGemInDiscard(
            session: &session,
            gemID: session.gemsInHand[0].id
        )
        assertFailure(earlyDiscard, .discardNotRequired)
    }

    func testDestinationBecomesDiscardAfterExactlyOneFullRotation() {
        let cupCount = 11
        var session = makePlayingSession(bag: [])
        session.gemsInHand = makeHand(count: cupCount + 2)
        session.currentRoll = cupCount + 2
        session.nextPlacementCupIndex = 0

        for _ in 0..<cupCount {
            placeNextHandGem(session: &session)
        }

        XCTAssertEqual(session.placementsCompletedInCurrentRotation, cupCount)
        XCTAssertEqual(GameTurnEngine.currentPlacementDestination(in: session), .discard)
        XCTAssertEqual(session.gemsInHand.count, 2)
        XCTAssertFalse(session.isTurnPlacementComplete)
        XCTAssertTrue(session.recentResolutionEvents.isEmpty)
    }

    func testDiscardOccursWhileGemsRemainInHand() {
        let cupCount = 11
        var session = makePlayingSession(bag: [])
        session.gemsInHand = makeHand(count: cupCount + 3)
        session.currentRoll = cupCount + 3
        session.nextPlacementCupIndex = 0

        for _ in 0..<cupCount {
            placeNextHandGem(session: &session)
        }

        XCTAssertEqual(GameTurnEngine.currentPlacementDestination(in: session), .discard)
        XCTAssertEqual(session.gemsInHand.count, 3)

        let selected = session.gemsInHand[1]
        let handBefore = session.gemsInHand
        let result = GameTurnEngine.placeGemInDiscard(session: &session, gemID: selected.id)

        assertSuccess(result)
        XCTAssertEqual(session.discardPile.map(\.id), [selected.id])
        XCTAssertEqual(session.gemsInHand.count, 2)
        XCTAssertFalse(session.gemsInHand.contains(where: { $0.id == selected.id }))
        XCTAssertEqual(
            Set(session.gemsInHand.map(\.id)),
            Set(handBefore.map(\.id).filter { $0 != selected.id })
        )
        XCTAssertEqual(GameTurnEngine.currentPlacementDestination(in: session), .cup(index: 0))
        XCTAssertFalse(session.isTurnPlacementComplete)
    }

    func testResumeBoardPlacementAfterDiscardStartsNewRotation() {
        let cupCount = 11
        var session = makePlayingSession(bag: [])
        session.gemsInHand = makeHand(count: cupCount + 2)
        session.currentRoll = cupCount + 2
        session.nextPlacementCupIndex = 0

        for _ in 0..<cupCount {
            placeNextHandGem(session: &session)
        }
        discardFirstHandGem(session: &session)

        XCTAssertEqual(session.placementsCompletedInCurrentRotation, 0)
        XCTAssertEqual(GameTurnEngine.currentPlacementDestination(in: session), .cup(index: 0))

        placeNextHandGem(session: &session)

        XCTAssertEqual(session.placementsCompletedInCurrentRotation, 1)
        XCTAssertEqual(GameTurnEngine.currentPlacementDestination(in: session), .cup(index: 1))
    }

    func testTwoFullRotationsEachRequireDiscard() {
        let cupCount = 11
        // 2 rotations + 2 discards + 2 gems still in hand afterward.
        var session = makePlayingSession(bag: [])
        session.gemsInHand = makeHand(count: cupCount * 2 + 4)
        session.currentRoll = cupCount * 2 + 4
        session.nextPlacementCupIndex = 0

        for _ in 0..<cupCount {
            placeNextHandGem(session: &session)
        }
        XCTAssertEqual(GameTurnEngine.currentPlacementDestination(in: session), .discard)
        discardFirstHandGem(session: &session)

        for _ in 0..<cupCount {
            placeNextHandGem(session: &session)
        }
        XCTAssertEqual(GameTurnEngine.currentPlacementDestination(in: session), .discard)
        discardFirstHandGem(session: &session)

        XCTAssertEqual(session.discardPile.count, 2)
        XCTAssertEqual(GameTurnEngine.currentPlacementDestination(in: session), .cup(index: 0))
        XCTAssertEqual(session.gemsInHand.count, 2)
        XCTAssertFalse(session.isTurnPlacementComplete)
    }

    func testThreeFullRotationsEachRequireDiscard() {
        let cupCount = 11
        // 3 rotations + 3 discards + 1 gem still in hand afterward.
        var session = makePlayingSession(bag: [])
        session.gemsInHand = makeHand(count: cupCount * 3 + 4)
        session.currentRoll = cupCount * 3 + 4
        session.nextPlacementCupIndex = 0

        for rotation in 1...3 {
            for _ in 0..<cupCount {
                placeNextHandGem(session: &session)
            }
            XCTAssertEqual(
                GameTurnEngine.currentPlacementDestination(in: session),
                .discard,
                "Expected discard after rotation \(rotation)"
            )
            discardFirstHandGem(session: &session)
        }

        XCTAssertEqual(session.discardPile.count, 3)
        XCTAssertEqual(GameTurnEngine.currentPlacementDestination(in: session), .cup(index: 0))
        XCTAssertEqual(session.gemsInHand.count, 1)
        XCTAssertFalse(session.isTurnPlacementComplete)
    }

    func testEarlyDiscardIsRejectedWithoutMutation() {
        var session = makePlayingSession(bag: [])
        let gem = Gem(kind: .pink)
        session.gemsInHand = [gem, Gem(kind: .blue)]
        session.currentRoll = 2
        session.nextPlacementCupIndex = 0
        session.placementsCompletedInCurrentRotation = 3

        let result = GameTurnEngine.placeGemInDiscard(session: &session, gemID: gem.id)

        assertFailure(result, .discardNotRequired)
        XCTAssertEqual(session.gemsInHand.count, 2)
        XCTAssertTrue(session.discardPile.isEmpty)
        XCTAssertEqual(session.placementsCompletedInCurrentRotation, 3)
    }

    func testDuplicateDiscardAtSameBoundaryIsRejected() {
        let cupCount = 11
        var session = makePlayingSession(bag: [])
        session.gemsInHand = makeHand(count: cupCount + 3)
        session.currentRoll = cupCount + 3
        session.nextPlacementCupIndex = 0

        for _ in 0..<cupCount {
            placeNextHandGem(session: &session)
        }
        discardFirstHandGem(session: &session)

        let attempted = session.gemsInHand[0]
        let handCountBefore = session.gemsInHand.count
        let discardCountBefore = session.discardPile.count
        let result = GameTurnEngine.placeGemInDiscard(session: &session, gemID: attempted.id)

        assertFailure(result, .discardNotRequired)
        XCTAssertEqual(session.gemsInHand.count, handCountBefore)
        XCTAssertEqual(session.discardPile.count, discardCountBefore)
    }

    func testCupPlacementRejectedWhileDiscardRequired() {
        var session = makePlayingSession(bag: [])
        let gem = Gem(kind: .red)
        session.gemsInHand = [gem, Gem(kind: .blue)]
        session.currentRoll = 2
        session.nextPlacementCupIndex = 0
        session.placementsCompletedInCurrentRotation = session.cups.count

        let result = GameTurnEngine.placeGemInCurrentCup(session: &session, gemID: gem.id)

        assertFailure(result, .placementRequiresDiscard)
        XCTAssertEqual(session.gemsInHand.count, 2)
        XCTAssertTrue(session.cups[0].gems.isEmpty)
    }

    func testCompletedCupShortensRotationPath() {
        var session = makePlayingSession(bag: [])
        markCompleted(&session, cupIndex: 2)
        let available = GameTurnEngine.availablePlacementCupCount(in: session)
        XCTAssertEqual(available, 10)

        session.gemsInHand = makeHand(count: available + 1)
        session.currentRoll = available + 1
        session.nextPlacementCupIndex = 0

        for _ in 0..<available {
            placeNextHandGem(session: &session)
        }

        XCTAssertEqual(GameTurnEngine.currentPlacementDestination(in: session), .discard)
        XCTAssertEqual(session.gemsInHand.count, 1)
        XCTAssertTrue(session.cups[2].gems.isEmpty)
    }

    func testMultipleCompletedCupsShortenRotationWithoutInfiniteLoop() {
        var session = makePlayingSession(bag: [])
        for index in [0, 1, 2, 3, 4] {
            markCompleted(&session, cupIndex: index)
        }
        let available = GameTurnEngine.availablePlacementCupCount(in: session)
        XCTAssertEqual(available, 6)

        session.gemsInHand = makeHand(count: available + 2)
        session.currentRoll = available + 2
        session.nextPlacementCupIndex = GameTurnEngine.firstAvailablePlacementCupIndex(in: session) ?? 5

        for _ in 0..<available {
            placeNextHandGem(session: &session)
        }

        XCTAssertEqual(GameTurnEngine.currentPlacementDestination(in: session), .discard)
        discardFirstHandGem(session: &session)
        XCTAssertEqual(
            GameTurnEngine.currentPlacementDestination(in: session),
            .cup(index: session.nextPlacementCupIndex)
        )
        XCTAssertFalse(session.cups[session.nextPlacementCupIndex].isCompleted)
    }

    func testScoopDuringRotationPreservesProgress() {
        var session = makePlayingSession(bag: [])
        session.gemsInHand = makeHand(count: 3)
        session.currentRoll = 3
        session.nextPlacementCupIndex = 0
        session.placementsCompletedInCurrentRotation = 4
        session.cups[0].gems = [Gem(kind: .gold), Gem(kind: .gold)]

        // Non-final placements do not scoop; progress should still increment.
        placeNextHandGem(session: &session)
        XCTAssertEqual(session.placementsCompletedInCurrentRotation, 5)
        XCTAssertEqual(session.cups[0].gems.count, 3)

        // Final gem of this mini-hand scoops and continues.
        session.gemsInHand = [Gem(kind: .blue)]
        session.nextPlacementCupIndex = 1
        session.cups[1].gems = [Gem(kind: .orange)]
        placeNextHandGem(session: &session)

        XCTAssertEqual(session.placementsCompletedInCurrentRotation, 6)
        XCTAssertFalse(session.isTurnPlacementComplete)
        XCTAssertEqual(session.gemsInHand.count, 2)
        XCTAssertEqual(GameTurnEngine.currentPlacementDestination(in: session), .cup(index: 2))
    }

    func testScoopCanExtendPlacementIntoAnotherRotationDiscard() {
        let cupCount = 11
        var session = makePlayingSession(bag: [])
        session.gemsInHand = makeHand(count: cupCount)
        session.currentRoll = cupCount
        session.nextPlacementCupIndex = 0

        for _ in 0..<(cupCount - 1) {
            placeNextHandGem(session: &session)
        }

        // Final gem of original hand lands on a loaded cup → scoop continues the chain.
        let scoopedExtras = makeHand(count: cupCount + 1, kind: .gold)
        session.cups[session.nextPlacementCupIndex].gems = scoopedExtras
        placeNextHandGem(session: &session)

        XCTAssertEqual(GameTurnEngine.currentPlacementDestination(in: session), .discard)
        XCTAssertEqual(session.gemsInHand.count, scoopedExtras.count + 1)
        XCTAssertFalse(session.isTurnPlacementComplete)

        discardFirstHandGem(session: &session)
        XCTAssertEqual(GameTurnEngine.currentPlacementDestination(in: session), .cup(index: 0))

        for _ in 0..<cupCount {
            placeNextHandGem(session: &session)
        }

        XCTAssertEqual(GameTurnEngine.currentPlacementDestination(in: session), .discard)
        XCTAssertEqual(session.discardPile.count, 1)
        XCTAssertFalse(session.isTurnPlacementComplete)
    }

    func testUndoAfterDiscardRestoresHandDiscardAndRotationState() async {
        await MainActor.run {
            let cupCount = 11
            var session = makePlayingSession(bag: [])
            session.gemsInHand = makeHand(count: cupCount + 2)
            session.currentRoll = cupCount + 2
            session.nextPlacementCupIndex = 0
            session.phase = .playing

            let viewModel = GameViewModel(session: session)
            for _ in 0..<cupCount {
                guard let gemID = viewModel.session.gemsInHand.first?.id else {
                    return XCTFail("Expected gem in hand")
                }
                _ = viewModel.placeGemInCurrentCup(gemID: gemID)
            }

            XCTAssertEqual(viewModel.currentPlacementDestination, .discard)
            let handBeforeDiscard = viewModel.session.gemsInHand
            let discardBefore = viewModel.session.discardPile
            let rotationBefore = viewModel.session.placementsCompletedInCurrentRotation
            let destinationBefore = viewModel.currentPlacementDestination

            guard let discardGemID = viewModel.session.gemsInHand.first?.id else {
                return XCTFail("Expected gem for discard")
            }
            _ = viewModel.placeGemInDiscard(gemID: discardGemID)
            XCTAssertEqual(viewModel.session.discardPile.count, discardBefore.count + 1)

            viewModel.undoLastPlacement()

            XCTAssertEqual(viewModel.session.gemsInHand.map(\.id), handBeforeDiscard.map(\.id))
            XCTAssertEqual(viewModel.session.discardPile.map(\.id), discardBefore.map(\.id))
            XCTAssertEqual(viewModel.session.placementsCompletedInCurrentRotation, rotationBefore)
            XCTAssertEqual(viewModel.currentPlacementDestination, destinationBefore)
        }
    }

    func testRotationAndDiscardDoNotTriggerEndOfTurnResolution() {
        let cupCount = 11
        var session = makePlayingSession(bag: [])
        session.gemsInHand = makeHand(count: cupCount + 2)
        session.currentRoll = cupCount + 2
        session.nextPlacementCupIndex = 0
        session.unicornCupIndex = 0
        session.unicornCupID = session.cups[0].id
        // White gem in unicorn cup would be discarded by unicorn resolution if it ran.
        session.cups[0].gems = [Gem(kind: .white)]
        session.cups[3].gems = [Gem(kind: .black), Gem(kind: .red)]

        for _ in 0..<cupCount {
            placeNextHandGem(session: &session)
        }

        XCTAssertEqual(GameTurnEngine.currentPlacementDestination(in: session), .discard)
        XCTAssertFalse(session.isTurnPlacementComplete)
        XCTAssertTrue(session.recentResolutionEvents.isEmpty)
        XCTAssertTrue(session.pendingScoreChoices.isEmpty)
        // Unicorn cup still has its white gem — resolution has not run.
        XCTAssertEqual(session.cups[0].gems.filter { $0.kind == .white }.count, 1)
        XCTAssertEqual(session.cups[3].gems.filter { $0.kind == .black }.count, 1)

        discardFirstHandGem(session: &session)

        XCTAssertFalse(session.isTurnPlacementComplete)
        XCTAssertTrue(session.recentResolutionEvents.isEmpty)
        XCTAssertTrue(session.pendingScoreChoices.isEmpty)
        XCTAssertEqual(session.cups[0].gems.filter { $0.kind == .white }.count, 1)
        XCTAssertEqual(session.cups[3].gems.filter { $0.kind == .black }.count, 1)
    }

    func testNormalPlacementBeforeFirstRotationBoundaryUnchanged() {
        let first = Gem(kind: .red)
        let second = Gem(kind: .blue)
        var session = makePlayingSession(bag: [])
        session.gemsInHand = [first, second]
        session.currentRoll = 2
        session.nextPlacementCupIndex = 0

        _ = GameTurnEngine.placeGemInCurrentCup(session: &session, gemID: first.id)

        XCTAssertEqual(session.nextPlacementCupIndex, 1)
        XCTAssertEqual(session.placementsCompletedInCurrentRotation, 1)
        XCTAssertEqual(GameTurnEngine.currentPlacementDestination(in: session), .cup(index: 1))
        XCTAssertEqual(session.cups[0].gems.map(\.id), [first.id])
        XCTAssertEqual(session.gemsInHand.map(\.id), [second.id])
        XCTAssertFalse(session.isTurnPlacementComplete)
    }
}
