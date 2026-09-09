//
// WhiteGemDecisionEngineTests.swift
// LepreCONTests
//
// Two independent white-gem pauses: placement-chain scoop vs end-turn,
// and end-of-turn unicorn explode vs calm.
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
        session.unicornCupIndex = 9
        session.unicornCupID = session.cups[9].id
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

    // MARK: - Rule 1: placement chain

    func testFinalNonWhiteLandingOnExistingWhitePausesScoop() {
        let blue = Gem(kind: .blue)
        let white = Gem(kind: .white)
        let red = Gem(kind: .red)
        var session = makePlayingSession()
        session.gemsInHand = [blue]
        session.currentRoll = 1
        session.nextPlacementCupIndex = 2
        session.cups[2].gems = [white, red]

        _ = GameTurnEngine.placeGemInCurrentCup(session: &session, gemID: blue.id)

        XCTAssertEqual(session.pendingWhiteGemDecision, .endPlacementChain(cupIndex: 2))
        XCTAssertFalse(session.isTurnPlacementComplete)
        XCTAssertEqual(session.cups[2].gems.map(\.id), [white.id, red.id, blue.id])
        XCTAssertTrue(session.gemsInHand.isEmpty)
        XCTAssertTrue(session.discardPile.isEmpty)
    }

    func testFinalWhiteLandingOnNonEmptyCupPausesScoop() {
        let white = Gem(kind: .white)
        let red = Gem(kind: .red)
        let blue = Gem(kind: .blue)
        var session = makePlayingSession()
        session.gemsInHand = [white]
        session.currentRoll = 1
        session.nextPlacementCupIndex = 2
        session.cups[2].gems = [red, blue]

        _ = GameTurnEngine.placeGemInCurrentCup(session: &session, gemID: white.id)

        XCTAssertEqual(session.pendingWhiteGemDecision, .endPlacementChain(cupIndex: 2))
        XCTAssertFalse(session.isTurnPlacementComplete)
        XCTAssertEqual(session.cups[2].gems.map(\.id), [red.id, blue.id, white.id])
        XCTAssertTrue(session.gemsInHand.isEmpty)
        XCTAssertTrue(session.discardPile.isEmpty)
    }

    func testChooseScoopContinuesPlacementWithAllGemsIncludingWhite() {
        let white = Gem(kind: .white)
        let red = Gem(kind: .red)
        let blue = Gem(kind: .blue)
        var session = makePlayingSession()
        session.cups[2].gems = [white, red, blue]
        session.pendingWhiteGemDecision = .endPlacementChain(cupIndex: 2)
        session.currentRoll = 3
        session.nextPlacementCupIndex = 2
        session.gemsInHand = []

        let result = WhiteGemDecisionEngine.resolvePlacementChain(
            session: &session,
            scoopAndContinue: true
        )

        assertSuccess(result)
        XCTAssertNil(session.pendingWhiteGemDecision)
        XCTAssertFalse(session.isTurnPlacementComplete)
        XCTAssertTrue(session.cups[2].gems.isEmpty)
        XCTAssertEqual(Set(session.gemsInHand.map(\.id)), Set([white.id, red.id, blue.id]))
        XCTAssertTrue(session.discardPile.isEmpty)
        XCTAssertEqual(session.nextPlacementCupIndex, 3)
        XCTAssertTrue(GameTurnEngine.canPlaceFromHand(in: session))
    }

    func testChooseUseWhiteEndsTurnAndDiscardsExactlyOneWhite() {
        let white = Gem(kind: .white)
        let red = Gem(kind: .red)
        let blue = Gem(kind: .blue)
        var session = makePlayingSession()
        session.cups[2].gems = [white, red, blue]
        session.pendingWhiteGemDecision = .endPlacementChain(cupIndex: 2)
        session.currentRoll = 1
        session.nextPlacementCupIndex = 2
        session.gemsInHand = []

        let result = WhiteGemDecisionEngine.resolvePlacementChain(
            session: &session,
            scoopAndContinue: false
        )

        assertSuccess(result)
        XCTAssertNil(session.pendingWhiteGemDecision)
        XCTAssertTrue(session.isTurnPlacementComplete)
        XCTAssertEqual(session.discardPile.map(\.id), [white.id])
        XCTAssertEqual(session.cups[2].gems.map(\.id), [red.id, blue.id])
        XCTAssertTrue(session.gemsInHand.isEmpty)
    }

    func testEndingPlacementChainWithMultipleWhitesConsumesExactlyOne() {
        let whiteA = Gem(kind: .white)
        let whiteB = Gem(kind: .white)
        let red = Gem(kind: .red)
        var session = makePlayingSession()
        session.cups[3].gems = [whiteA, red, whiteB]
        session.pendingWhiteGemDecision = .endPlacementChain(cupIndex: 3)
        session.currentRoll = 1
        session.nextPlacementCupIndex = 3

        _ = WhiteGemDecisionEngine.resolvePlacementChain(
            session: &session,
            scoopAndContinue: false
        )

        XCTAssertEqual(session.discardPile.count, 1)
        XCTAssertEqual(session.discardPile.first?.kind, .white)
        XCTAssertEqual(session.cups[3].gems.filter { $0.kind == .white }.count, 1)
        XCTAssertTrue(session.cups[3].gems.contains(where: { $0.id == red.id }))
    }

    func testLandingCupWithoutWhiteStillAutoScoops() {
        let finalGem = Gem(kind: .blue)
        let existing = Gem(kind: .red)
        var session = makePlayingSession()
        session.gemsInHand = [finalGem]
        session.currentRoll = 1
        session.nextPlacementCupIndex = 2
        session.cups[2].gems = [existing]

        _ = GameTurnEngine.placeGemInCurrentCup(session: &session, gemID: finalGem.id)

        XCTAssertNil(session.pendingWhiteGemDecision)
        XCTAssertFalse(session.isTurnPlacementComplete)
        XCTAssertTrue(session.cups[2].gems.isEmpty)
        XCTAssertEqual(Set(session.gemsInHand.map(\.id)), Set([existing.id, finalGem.id]))
    }

    func testFinalGemOnEmptyCupDoesNotCreatePlacementChainDecisionEvenIfWhite() {
        let white = Gem(kind: .white)
        var session = makePlayingSession()
        session.gemsInHand = [white]
        session.currentRoll = 1
        session.nextPlacementCupIndex = 2
        session.cups[2].gems = []

        _ = GameTurnEngine.placeGemInCurrentCup(session: &session, gemID: white.id)

        XCTAssertNotEqual(session.pendingWhiteGemDecision, .endPlacementChain(cupIndex: 2))
        XCTAssertTrue(session.isTurnPlacementComplete)
        XCTAssertEqual(session.cups[2].gems.map(\.id), [white.id])
    }

    // MARK: - Rule 2: unicorn spread

    func testUnicornCupWithWhitePausesExplodeAtEndOfTurn() {
        var session = makePlayingSession()
        placeUnicorn(on: 4, in: &session)
        let white = Gem(kind: .white)
        let red = Gem(kind: .red)
        session.cups[4].gems = [white, red]
        session.isTurnPlacementComplete = true

        EndOfTurnResolver.resolveAfterPlacementEnds(session: &session)

        XCTAssertEqual(session.pendingWhiteGemDecision, .stopUnicornSpread(cupIndex: 4))
        XCTAssertEqual(session.unicornCupIndex, 4)
        XCTAssertEqual(session.cups[4].gems.map(\.id), [white.id, red.id])
        XCTAssertTrue(session.discardPile.isEmpty)
        XCTAssertTrue(session.recentResolutionEvents.isEmpty)
        XCTAssertTrue(session.pendingScoreChoices.isEmpty)
    }

    func testChooseExplodePerformsExistingClockwiseSpreadAndMovesUnicorn() {
        var session = makePlayingSession()
        placeUnicorn(on: 2, in: &session)
        let white = Gem(kind: .white)
        let red = Gem(kind: .red)
        session.cups[2].gems = [white, red]
        session.pendingWhiteGemDecision = .stopUnicornSpread(cupIndex: 2)
        session.isTurnPlacementComplete = true

        let result = WhiteGemDecisionEngine.resolveUnicornSpread(
            session: &session,
            explode: true
        )

        assertSuccess(result)
        XCTAssertNil(session.pendingWhiteGemDecision)
        XCTAssertTrue(session.cups[2].gems.isEmpty)
        XCTAssertEqual(session.cups[3].gems.map(\.id), [white.id])
        XCTAssertEqual(session.cups[4].gems.map(\.id), [red.id])
        XCTAssertEqual(session.unicornCupIndex, 4)
    }

    func testChooseCalmDiscardsOneWhiteLeavesOthersAndDoesNotMoveUnicorn() {
        var session = makePlayingSession()
        placeUnicorn(on: 5, in: &session)
        let white = Gem(kind: .white)
        let green = Gem(kind: .green)
        session.cups[5].gems = [white, green]
        session.cups[6].gems = gems(Array(repeating: .blue, count: 5))
        session.pendingWhiteGemDecision = .stopUnicornSpread(cupIndex: 5)
        session.isTurnPlacementComplete = true
        let unicornID = session.unicornCupID

        let result = WhiteGemDecisionEngine.resolveUnicornSpread(
            session: &session,
            explode: false
        )

        assertSuccess(result)
        XCTAssertNil(session.pendingWhiteGemDecision)
        XCTAssertEqual(session.unicornCupIndex, 5)
        XCTAssertEqual(session.unicornCupID, unicornID)
        XCTAssertEqual(session.discardPile.map(\.id), [white.id])
        XCTAssertEqual(session.cups[5].gems.map(\.id), [green.id])
        XCTAssertEqual(session.pendingScoreChoices.first?.cupIndex, 6)
        XCTAssertFalse(
            session.recentResolutionEvents.contains {
                if case .unicornExplosionStarted = $0 { return true }
                return false
            }
        )
        XCTAssertTrue(session.recentResolutionEvents.contains(.unicornCalmed(cupIndex: 5)))
    }

    func testCalmingUnicornWithMultipleWhitesConsumesExactlyOne() {
        var session = makePlayingSession()
        placeUnicorn(on: 1, in: &session)
        let whiteA = Gem(kind: .white)
        let whiteB = Gem(kind: .white)
        let gold = Gem(kind: .gold)
        session.cups[1].gems = [whiteA, gold, whiteB]
        session.pendingWhiteGemDecision = .stopUnicornSpread(cupIndex: 1)
        session.isTurnPlacementComplete = true

        _ = WhiteGemDecisionEngine.resolveUnicornSpread(session: &session, explode: false)

        XCTAssertEqual(session.discardPile.count, 1)
        XCTAssertEqual(session.discardPile.first?.kind, .white)
        XCTAssertEqual(session.cups[1].gems.filter { $0.kind == .white }.count, 1)
        XCTAssertTrue(session.cups[1].gems.contains(where: { $0.id == gold.id }))
        XCTAssertEqual(session.unicornCupIndex, 1)
    }

    func testUnicornCupWithoutWhiteStillExplodesAutomatically() {
        var session = makePlayingSession()
        placeUnicorn(on: 2, in: &session)
        session.cups[2].gems = gems([.red, .blue])

        EndOfTurnResolver.resolveAfterPlacementEnds(session: &session)

        XCTAssertNil(session.pendingWhiteGemDecision)
        XCTAssertTrue(session.cups[2].gems.isEmpty)
        XCTAssertEqual(session.unicornCupIndex, 4)
    }

    func testWhiteInADifferentCupDoesNotPauseUnicornResolution() {
        var session = makePlayingSession()
        placeUnicorn(on: 2, in: &session)
        session.cups[2].gems = gems([.red])
        session.cups[6].gems = gems([.white, .green])

        EndOfTurnResolver.resolveAfterPlacementEnds(session: &session)

        XCTAssertNil(session.pendingWhiteGemDecision)
        XCTAssertTrue(session.cups[2].gems.isEmpty)
        XCTAssertEqual(session.unicornCupIndex, 3)
        XCTAssertEqual(session.cups[6].gems.map(\.kind), [.white, .green])
    }

    func testUsingWhiteToEndTurnCanLeadToSeparateUnicornChoice() {
        let landingWhite = Gem(kind: .white)
        let landingRed = Gem(kind: .red)
        let unicornWhite = Gem(kind: .white)
        let unicornBlue = Gem(kind: .blue)
        var session = makePlayingSession()
        placeUnicorn(on: 6, in: &session)
        session.cups[2].gems = [landingWhite, landingRed]
        session.cups[6].gems = [unicornWhite, unicornBlue]
        session.pendingWhiteGemDecision = .endPlacementChain(cupIndex: 2)
        session.currentRoll = 1
        session.nextPlacementCupIndex = 2

        let chainResult = WhiteGemDecisionEngine.resolvePlacementChain(
            session: &session,
            scoopAndContinue: false
        )

        assertSuccess(chainResult)
        XCTAssertEqual(session.discardPile.map(\.id), [landingWhite.id])
        XCTAssertEqual(session.cups[2].gems.map(\.id), [landingRed.id])
        XCTAssertTrue(session.isTurnPlacementComplete)
        XCTAssertEqual(session.pendingWhiteGemDecision, .stopUnicornSpread(cupIndex: 6))
        XCTAssertEqual(session.unicornCupIndex, 6)
        XCTAssertEqual(session.cups[6].gems.map(\.id), [unicornWhite.id, unicornBlue.id])
        XCTAssertTrue(session.pendingScoreChoices.isEmpty)

        let unicornResult = WhiteGemDecisionEngine.resolveUnicornSpread(
            session: &session,
            explode: false
        )

        assertSuccess(unicornResult)
        XCTAssertNil(session.pendingWhiteGemDecision)
        XCTAssertEqual(session.discardPile.map(\.id), [landingWhite.id, unicornWhite.id])
        XCTAssertEqual(session.cups[6].gems.map(\.id), [unicornBlue.id])
        XCTAssertEqual(session.unicornCupIndex, 6)
    }

    func testPlacementIsBlockedWhileEitherWhiteDecisionIsPending() {
        var session = makePlayingSession()
        session.pendingWhiteGemDecision = .endPlacementChain(cupIndex: 2)
        session.currentRoll = 2
        session.isTurnPlacementComplete = false
        let extra = Gem(kind: .blue)
        session.gemsInHand = [extra]
        session.nextPlacementCupIndex = 3

        XCTAssertFalse(GameTurnEngine.canPlaceFromHand(in: session))
        let placed = GameTurnEngine.placeGemInCurrentCup(session: &session, gemID: extra.id)
        switch placed {
        case .success:
            XCTFail("Expected pending white-gem decision to block placement")
        case .failure(let error):
            XCTAssertEqual(error, .pendingWhiteGemDecisionUnresolved)
        }
        XCTAssertEqual(session.gemsInHand.map(\.id), [extra.id])
    }

    func testPoopAndScoringDoNotRunBeforeUnicornWhiteDecision() {
        var session = makePlayingSession()
        placeUnicorn(on: 2, in: &session)
        session.cups[2].gems = gems([.white, .red])
        session.cups[3].gems = gems([.black, .green])
        session.cups[6].gems = gems(Array(repeating: .blue, count: 5))
        session.isTurnPlacementComplete = true

        EndOfTurnResolver.resolveAfterPlacementEnds(session: &session)

        XCTAssertEqual(session.pendingWhiteGemDecision, .stopUnicornSpread(cupIndex: 2))
        XCTAssertEqual(session.cups[3].gems.count, 2)
        XCTAssertTrue(session.pendingScoreChoices.isEmpty)
    }
}
