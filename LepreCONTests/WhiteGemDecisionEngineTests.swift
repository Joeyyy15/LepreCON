//
// WhiteGemDecisionEngineTests.swift
// LepreCONTests
//
// Pending white-gem / unicorn decisions: pause, choices, and non-white preservation.
//

import XCTest
@testable import LepreCON

final class WhiteGemDecisionEngineTests: XCTestCase {

    private func gems(_ kinds: [GemKind]) -> [Gem] {
        kinds.map { Gem(kind: $0) }
    }

    private func makePlayingSession() -> GameSession {
        var session = GameSessionFactory().makeNewGame(playerNames: ["Alex"])
        session.phase = .playing
        for index in session.cups.indices {
            session.cups[index].gems = []
        }
        return session
    }

    private func placeUnicorn(on cupIndex: Int, in session: inout GameSession) {
        session.unicornCupIndex = cupIndex
        session.unicornCupID = session.cups[cupIndex].id
    }

    private func assertSuccess(
        _ result: Result<Void, WhiteGemDecisionError>,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        if case .failure(let error) = result {
            XCTFail("Expected success, got \(error)", file: file, line: line)
        }
    }

    private func assertTurnError(
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

    // MARK: - Pending trigger

    func testExistingWhiteGemInUnicornCupTriggersPendingDecisionOnEndOfTurn() {
        var session = makePlayingSession()
        placeUnicorn(on: 4, in: &session)
        let white = Gem(kind: .white)
        let red = Gem(kind: .red)
        session.cups[4].gems = [white, red]
        session.isTurnPlacementComplete = true

        EndOfTurnResolver.resolveAfterPlacementEnds(session: &session)

        XCTAssertEqual(session.pendingWhiteGemDecision?.cupIndex, 4)
        XCTAssertTrue(session.isTurnPlacementComplete)
        XCTAssertEqual(session.unicornCupIndex, 4)
        XCTAssertEqual(session.cups[4].gems.map(\.id), [white.id, red.id])
        XCTAssertTrue(session.discardPile.isEmpty)
        XCTAssertTrue(session.recentResolutionEvents.isEmpty)
        XCTAssertTrue(session.pendingScoreChoices.isEmpty)
    }

    func testNewlyPlacedWhiteAsFinalGemOnUnicornCupTriggersPendingDecision() {
        let white = Gem(kind: .white)
        var session = makePlayingSession()
        placeUnicorn(on: 0, in: &session)
        session.gemsInHand = [white]
        session.currentRoll = 1
        session.nextPlacementCupIndex = 0
        session.cups[0].gems = []

        let result = GameTurnEngine.placeGemInCurrentCup(session: &session, gemID: white.id)

        XCTAssertTrue(result.isSuccess)
        XCTAssertEqual(session.pendingWhiteGemDecision?.cupIndex, 0)
        XCTAssertFalse(session.isTurnPlacementComplete)
        XCTAssertEqual(session.cups[0].gems.map(\.id), [white.id])
        XCTAssertTrue(session.gemsInHand.isEmpty)
        XCTAssertEqual(session.unicornCupIndex, 0)
        XCTAssertTrue(session.recentResolutionEvents.isEmpty)
        XCTAssertTrue(session.pendingScoreChoices.isEmpty)
    }

    func testExistingWhiteInUnicornCupPausesWhenFinalGemLandsThere() {
        let finalGem = Gem(kind: .red)
        let white = Gem(kind: .white)
        let gold = Gem(kind: .gold)
        var session = makePlayingSession()
        placeUnicorn(on: 0, in: &session)
        session.gemsInHand = [finalGem]
        session.currentRoll = 1
        session.nextPlacementCupIndex = 0
        session.cups[0].gems = [white, gold]

        _ = GameTurnEngine.placeGemInCurrentCup(session: &session, gemID: finalGem.id)

        XCTAssertEqual(session.pendingWhiteGemDecision?.cupIndex, 0)
        XCTAssertFalse(session.isTurnPlacementComplete)
        XCTAssertEqual(session.cups[0].gems.map(\.id), [white.id, gold.id, finalGem.id])
        XCTAssertTrue(session.gemsInHand.isEmpty)
        XCTAssertTrue(session.discardPile.isEmpty)
        XCTAssertEqual(session.unicornCupIndex, 0)
    }

    func testPendingDecisionDoesNotAutomaticallyExplodeOrMoveUnicorn() {
        var session = makePlayingSession()
        placeUnicorn(on: 2, in: &session)
        session.cups[2].gems = gems([.white, .blue])
        let unicornID = session.unicornCupID

        EndOfTurnResolver.resolveAfterPlacementEnds(session: &session)

        XCTAssertNotNil(session.pendingWhiteGemDecision)
        XCTAssertEqual(session.unicornCupIndex, 2)
        XCTAssertEqual(session.unicornCupID, unicornID)
        XCTAssertFalse(
            session.recentResolutionEvents.contains {
                if case .unicornExplosionStarted = $0 { return true }
                return false
            }
        )
        XCTAssertFalse(
            session.recentResolutionEvents.contains {
                if case .unicornMoved = $0 { return true }
                return false
            }
        )
        XCTAssertFalse(
            session.recentResolutionEvents.contains {
                if case .unicornCalmed = $0 { return true }
                return false
            }
        )
    }

    // MARK: - Player choices

    func testPlayerCanChooseToExplodeUnicorn() {
        var session = makePlayingSession()
        placeUnicorn(on: 2, in: &session)
        let white = Gem(kind: .white)
        let red = Gem(kind: .red)
        session.cups[2].gems = [white, red]
        session.pendingWhiteGemDecision = PendingWhiteGemDecision(cupIndex: 2)
        session.currentRoll = 1
        session.isTurnPlacementComplete = true

        let result = WhiteGemDecisionEngine.resolve(
            session: &session,
            triggerUnicorn: true,
            scoopAndContinue: false
        )

        assertSuccess(result)
        XCTAssertNil(session.pendingWhiteGemDecision)
        XCTAssertTrue(session.cups[2].gems.isEmpty)
        XCTAssertEqual(session.cups[3].gems.map(\.id), [white.id])
        XCTAssertEqual(session.cups[4].gems.map(\.id), [red.id])
        XCTAssertEqual(session.unicornCupIndex, 4)
        XCTAssertTrue(session.isTurnPlacementComplete)
    }

    func testPlayerCanChooseNotToTriggerUnicorn() {
        var session = makePlayingSession()
        placeUnicorn(on: 5, in: &session)
        let white = Gem(kind: .white)
        let green = Gem(kind: .green)
        session.cups[5].gems = [white, green]
        session.pendingWhiteGemDecision = PendingWhiteGemDecision(cupIndex: 5)
        session.currentRoll = 1
        session.isTurnPlacementComplete = true
        let unicornID = session.unicornCupID

        let result = WhiteGemDecisionEngine.resolve(
            session: &session,
            triggerUnicorn: false,
            scoopAndContinue: false
        )

        assertSuccess(result)
        XCTAssertNil(session.pendingWhiteGemDecision)
        XCTAssertEqual(session.unicornCupIndex, 5)
        XCTAssertEqual(session.unicornCupID, unicornID)
        XCTAssertEqual(session.discardPile.map(\.id), [white.id])
        XCTAssertEqual(session.cups[5].gems.map(\.id), [green.id])
        XCTAssertEqual(session.unicornCupIndex, 5)
        XCTAssertFalse(
            session.recentResolutionEvents.contains {
                if case .unicornExplosionStarted = $0 { return true }
                return false
            }
        )
    }

    func testPlayerCanScoopCupAndContinuePlacement() {
        let white = Gem(kind: .white)
        let red = Gem(kind: .red)
        var session = makePlayingSession()
        placeUnicorn(on: 0, in: &session)
        session.cups[0].gems = [white, red]
        session.pendingWhiteGemDecision = PendingWhiteGemDecision(cupIndex: 0)
        session.currentRoll = 2
        session.nextPlacementCupIndex = 0
        session.isTurnPlacementComplete = false
        session.gemsInHand = []

        let result = WhiteGemDecisionEngine.resolve(
            session: &session,
            triggerUnicorn: false,
            scoopAndContinue: true
        )

        assertSuccess(result)
        XCTAssertNil(session.pendingWhiteGemDecision)
        XCTAssertFalse(session.isTurnPlacementComplete)
        XCTAssertTrue(session.cups[0].gems.isEmpty)
        XCTAssertEqual(Set(session.gemsInHand.map(\.id)), Set([white.id, red.id]))
        XCTAssertEqual(session.nextPlacementCupIndex, 1)
        XCTAssertEqual(session.unicornCupIndex, 0)
        XCTAssertTrue(session.pendingScoreChoices.isEmpty)
        XCTAssertTrue(GameTurnEngine.canPlaceFromHand(in: session))
    }

    func testPlayerCanLeaveCupAndEndTheTurn() {
        var session = makePlayingSession()
        placeUnicorn(on: 2, in: &session)
        session.cups[2].gems = gems([.white]) + gems(Array(repeating: .red, count: 5))
        session.pendingWhiteGemDecision = PendingWhiteGemDecision(cupIndex: 2)
        session.currentRoll = 1
        session.isTurnPlacementComplete = false

        let result = WhiteGemDecisionEngine.resolve(
            session: &session,
            triggerUnicorn: false,
            scoopAndContinue: false
        )

        assertSuccess(result)
        XCTAssertNil(session.pendingWhiteGemDecision)
        XCTAssertTrue(session.isTurnPlacementComplete)
        XCTAssertTrue(session.gemsInHand.isEmpty)
        XCTAssertEqual(session.pendingScoreChoices.first?.cupIndex, 2)
        XCTAssertEqual(session.unicornCupIndex, 2)
    }

    // MARK: - Pause while unresolved

    func testPlacementIsBlockedWhileWhiteGemDecisionIsPending() {
        var session = makePlayingSession()
        placeUnicorn(on: 1, in: &session)
        session.cups[1].gems = gems([.white])
        session.pendingWhiteGemDecision = PendingWhiteGemDecision(cupIndex: 1)
        session.currentRoll = 2
        session.isTurnPlacementComplete = false
        let extra = Gem(kind: .blue)
        session.gemsInHand = [extra]
        session.nextPlacementCupIndex = 2

        XCTAssertFalse(GameTurnEngine.canPlaceFromHand(in: session))
        let placed = GameTurnEngine.placeGemInCurrentCup(session: &session, gemID: extra.id)
        assertTurnError(placed, .pendingWhiteGemDecisionUnresolved)
        XCTAssertEqual(session.gemsInHand.map(\.id), [extra.id])
        XCTAssertTrue(session.cups[2].gems.isEmpty)
        XCTAssertEqual(session.pendingWhiteGemDecision?.cupIndex, 1)
    }

    func testEndOfTurnResolutionDoesNotRunBeforeDecisionIsResolved() {
        var session = makePlayingSession()
        placeUnicorn(on: 2, in: &session)
        session.cups[2].gems = gems([.white, .red])
        session.cups[3].gems = gems([.black, .green])
        session.cups[6].gems = gems(Array(repeating: .blue, count: 5))
        session.isTurnPlacementComplete = true

        EndOfTurnResolver.resolveAfterPlacementEnds(session: &session)

        XCTAssertNotNil(session.pendingWhiteGemDecision)
        XCTAssertEqual(session.cups[3].gems.count, 2, "Poop should not discard yet")
        XCTAssertTrue(session.pendingScoreChoices.isEmpty, "Score detection should not run yet")
        XCTAssertTrue(session.recentResolutionEvents.isEmpty)
    }

    func testNonWhiteFinalGemOnEmptyCupStillEndsTurnWithoutPendingDecision() {
        let gem = Gem(kind: .clear)
        var session = makePlayingSession()
        placeUnicorn(on: 9, in: &session)
        session.gemsInHand = [gem]
        session.currentRoll = 1
        session.nextPlacementCupIndex = 0
        session.cups[0].gems = []

        _ = GameTurnEngine.placeGemInCurrentCup(session: &session, gemID: gem.id)

        XCTAssertNil(session.pendingWhiteGemDecision)
        XCTAssertTrue(session.isTurnPlacementComplete)
        XCTAssertEqual(session.cups[0].gems.map(\.id), [gem.id])
    }

    func testNonWhiteFinalGemOnOccupiedNonUnicornCupStillScoops() {
        let finalGem = Gem(kind: .clear)
        let existing = Gem(kind: .red)
        var session = makePlayingSession()
        placeUnicorn(on: 9, in: &session)
        session.gemsInHand = [finalGem]
        session.currentRoll = 1
        session.nextPlacementCupIndex = 0
        session.cups[0].gems = [existing]

        _ = GameTurnEngine.placeGemInCurrentCup(session: &session, gemID: finalGem.id)

        XCTAssertNil(session.pendingWhiteGemDecision)
        XCTAssertFalse(session.isTurnPlacementComplete)
        XCTAssertTrue(session.cups[0].gems.isEmpty)
        XCTAssertEqual(Set(session.gemsInHand.map(\.id)), Set([existing.id, finalGem.id]))
    }

    func testUnicornStillExplodesWhenNoWhiteGemIsPresent() {
        var session = makePlayingSession()
        placeUnicorn(on: 2, in: &session)
        session.cups[2].gems = gems([.red, .blue])

        EndOfTurnResolver.resolveAfterPlacementEnds(session: &session)

        XCTAssertNil(session.pendingWhiteGemDecision)
        XCTAssertTrue(session.cups[2].gems.isEmpty)
        XCTAssertEqual(session.unicornCupIndex, 4)
    }
}

private extension Result where Success == Void {
    var isSuccess: Bool {
        if case .success = self { return true }
        return false
    }
}
