//
// UnicornResolverTests.swift
// LepreCONTests
//
// Behavior tests for end-of-turn unicorn resolution.
//

import XCTest
@testable import LepreCON

final class UnicornResolverTests: XCTestCase {

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

    private func markCompleted(_ session: inout GameSession, cupIndex: Int) {
        session.cups[cupIndex].completion = CupCompletion(
            scoredColor: .red,
            wasMatchingCupColor: false,
            goodCount: 5,
            passCount: 0,
            blemishCount: 0,
            adjustedGoodCount: 5
        )
    }

    // MARK: - No unicorn

    func testResolveDoesNothingWhenUnicornCupIndexIsNil() {
        var session = makePlayingSession()
        session.cups[2].gems = gems([.red, .blue])
        session.unicornCupIndex = nil
        session.unicornCupID = nil

        let outcome = UnicornResolver.resolve(in: &session)

        XCTAssertEqual(outcome, .noUnicorn)
        XCTAssertEqual(session.cups[2].gems.count, 2)
        XCTAssertTrue(session.discardPile.isEmpty)
    }

    // MARK: - White calming

    func testWhiteGemInUnicornCupMovesExactlyOneWhiteToDiscard() {
        let white = Gem(kind: .white)
        var session = makePlayingSession()
        placeUnicorn(on: 3, in: &session)
        session.cups[3].gems = [white, Gem(kind: .red)]

        let outcome = UnicornResolver.resolve(in: &session)

        XCTAssertEqual(outcome, .calmedByWhite(cupIndex: 3))
        XCTAssertEqual(session.discardPile.count, 1)
        XCTAssertEqual(session.discardPile.first?.id, white.id)
        XCTAssertEqual(session.discardPile.first?.kind, .white)
    }

    func testWhiteCalmingLeavesOtherGemsInUnicornCup() {
        let red = Gem(kind: .red)
        let blue = Gem(kind: .blue)
        var session = makePlayingSession()
        placeUnicorn(on: 4, in: &session)
        session.cups[4].gems = [Gem(kind: .white), red, blue]

        _ = UnicornResolver.resolve(in: &session)

        XCTAssertEqual(session.cups[4].gems.map(\.id), [red.id, blue.id])
        XCTAssertEqual(session.cups[4].gems.map(\.kind), [.red, .blue])
    }

    func testWhiteGemInUnicornCupCalmsUnicorn() {
        let white = Gem(kind: .white)
        var session = makePlayingSession()
        placeUnicorn(on: 3, in: &session)
        session.cups[3].gems = [white]

        let outcome = UnicornResolver.resolve(in: &session)

        XCTAssertEqual(outcome, .calmedByWhite(cupIndex: 3))
        XCTAssertEqual(session.discardPile.map(\.kind), [.white])
        XCTAssertTrue(session.cups[3].gems.isEmpty)
    }

    func testClearGemInUnicornCupDoesNotCalmUnicorn() {
        let clear = Gem(kind: .clear)
        var session = makePlayingSession()
        placeUnicorn(on: 0, in: &session)
        session.cups[0].gems = [clear, Gem(kind: .red)]

        let outcome = UnicornResolver.resolve(in: &session)

        XCTAssertEqual(outcome, .exploded(fromCupIndex: 0, finalCupIndex: 2))
        XCTAssertTrue(session.discardPile.isEmpty)
        XCTAssertFalse(
            session.recentResolutionEvents.contains { event in
                if case .unicornCalmed(cupIndex: 0) = event { return true }
                return false
            }
        )
    }

    func testUnicornCupWithOnlyClearAndOtherNonWhiteGemsExplodes() {
        let clear = Gem(kind: .clear)
        let red = Gem(kind: .red)
        let gold = Gem(kind: .gold)
        var session = makePlayingSession()
        placeUnicorn(on: 4, in: &session)
        session.cups[4].gems = [clear, red, gold]

        let outcome = UnicornResolver.resolve(in: &session)

        XCTAssertEqual(outcome, .exploded(fromCupIndex: 4, finalCupIndex: 7))
        XCTAssertTrue(session.discardPile.isEmpty)
        XCTAssertTrue(session.cups[4].gems.isEmpty)
        XCTAssertEqual(session.cups[5].gems.map(\.id), [clear.id])
        XCTAssertEqual(session.cups[6].gems.map(\.id), [red.id])
        XCTAssertEqual(session.cups[7].gems.map(\.id), [gold.id])
    }

    func testCalmedByWhiteKeepsUnicornOnSameCup() {
        var session = makePlayingSession()
        placeUnicorn(on: 5, in: &session)
        session.cups[5].gems = gems([.white, .green])
        let originalCupID = session.unicornCupID

        _ = UnicornResolver.resolve(in: &session)

        XCTAssertEqual(session.unicornCupIndex, 5)
        XCTAssertEqual(session.unicornCupID, originalCupID)
    }

    // MARK: - Explosion

    func testExplosionSpreadsGemsClockwiseIntoFollowingCups() {
        let spreadGems = gems([.red, .blue, .green])
        var session = makePlayingSession()
        placeUnicorn(on: 2, in: &session)
        session.cups[2].gems = spreadGems

        _ = UnicornResolver.resolve(in: &session)

        XCTAssertTrue(session.cups[2].gems.isEmpty)
        XCTAssertEqual(session.cups[3].gems.map(\.id), [spreadGems[0].id])
        XCTAssertEqual(session.cups[4].gems.map(\.id), [spreadGems[1].id])
        XCTAssertEqual(session.cups[5].gems.map(\.id), [spreadGems[2].id])
    }

    func testExplosionClearsOriginalUnicornCup() {
        var session = makePlayingSession()
        placeUnicorn(on: 6, in: &session)
        session.cups[6].gems = gems([.purple, .orange])

        _ = UnicornResolver.resolve(in: &session)

        XCTAssertTrue(session.cups[6].gems.isEmpty)
    }

    func testExplosionDoesNotScoopGemsIntoHand() {
        var session = makePlayingSession()
        placeUnicorn(on: 2, in: &session)
        session.cups[2].gems = gems([.red, .blue])
        session.gemsInHand = []

        _ = UnicornResolver.resolve(in: &session)

        XCTAssertTrue(session.gemsInHand.isEmpty)
        XCTAssertEqual(session.cups[3].gems.count, 1)
        XCTAssertEqual(session.cups[4].gems.count, 1)
    }

    func testExplosionSkipsCompletedCups() {
        var session = makePlayingSession()
        placeUnicorn(on: 1, in: &session)
        session.cups[1].gems = gems([.red, .blue])
        markCompleted(&session, cupIndex: 2)

        _ = UnicornResolver.resolve(in: &session)

        XCTAssertTrue(session.cups[2].gems.isEmpty)
        XCTAssertEqual(session.cups[3].gems.count, 1)
        XCTAssertEqual(session.cups[3].gems.first?.kind, .red)
        XCTAssertEqual(session.cups[4].gems.count, 1)
        XCTAssertEqual(session.cups[4].gems.first?.kind, .blue)
    }

    func testExplosionCanPlaceGemsIntoPotOfGold() {
        var session = makePlayingSession()
        for index in 0..<GameSetup.potOfGoldCupIndex {
            markCompleted(&session, cupIndex: index)
        }
        let gold = Gem(kind: .gold)
        placeUnicorn(on: 9, in: &session)
        session.cups[9].gems = [gold]

        _ = UnicornResolver.resolve(in: &session)

        let potIndex = GameSetup.potOfGoldCupIndex
        XCTAssertEqual(session.cups[potIndex].gems.map(\.id), [gold.id])
    }

    func testExplosionMovesUnicornToFinalLandingCup() {
        var session = makePlayingSession()
        placeUnicorn(on: 2, in: &session)
        session.cups[2].gems = gems([.red, .blue, .green])

        let outcome = UnicornResolver.resolve(in: &session)

        XCTAssertEqual(outcome, .exploded(fromCupIndex: 2, finalCupIndex: 5))
        XCTAssertEqual(session.unicornCupIndex, 5)
    }

    func testExplosionSyncsUnicornCupIDWithNewCupIndex() {
        var session = makePlayingSession()
        placeUnicorn(on: 2, in: &session)
        session.cups[2].gems = gems([.yellow])

        _ = UnicornResolver.resolve(in: &session)

        XCTAssertEqual(session.unicornCupIndex, 3)
        XCTAssertEqual(session.unicornCupID, session.cups[3].id)
    }

    func testEmptyUnicornCupLeavesBoardUnchanged() {
        var session = makePlayingSession()
        placeUnicorn(on: 7, in: &session)
        session.cups[7].gems = []
        session.cups[8].gems = gems([.red])
        let originalCupID = session.unicornCupID

        let outcome = UnicornResolver.resolve(in: &session)

        XCTAssertEqual(outcome, .noGemsToExplode)
        XCTAssertEqual(session.unicornCupIndex, 7)
        XCTAssertEqual(session.unicornCupID, originalCupID)
        XCTAssertEqual(session.cups[8].gems.count, 1)
        XCTAssertTrue(session.discardPile.isEmpty)
    }

    // MARK: - End-of-turn ordering

    func testEndOfTurnResolverRunsUnicornBeforePendingScoreDetection() {
        var session = makePlayingSession()
        placeUnicorn(on: 2, in: &session)
        session.cups[2].gems = gems([.red])
        session.cups[3].gems = gems(Array(repeating: .red, count: 4))

        EndOfTurnResolver.resolveAfterPlacementEnds(session: &session)

        XCTAssertEqual(session.pendingScoreChoices.count, 1)
        XCTAssertEqual(session.pendingScoreChoices.first?.cupIndex, 3)
        XCTAssertEqual(session.unicornCupIndex, 3)
    }
}
