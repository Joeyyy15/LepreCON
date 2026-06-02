//
// PoopResolverTests.swift
// LepreCONTests
//
// Behavior tests for end-of-turn black gem (poop) resolution.
//

import XCTest
@testable import LepreCON

final class PoopResolverTests: XCTestCase {

    private func gems(_ kinds: [GemKind]) -> [Gem] {
        kinds.map { Gem(kind: $0) }
    }

    private func makePlayingSession() -> GameSession {
        var session = GameSessionFactory().makeNewGame(playerNames: ["Alex"])
        session.phase = .playing
        session.discardPile = []
        for index in session.cups.indices {
            session.cups[index].gems = []
        }
        return session
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

    // MARK: - No poop

    func testResolveDoesNothingWhenNoCupsContainBlackGems() {
        var session = makePlayingSession()
        session.cups[2].gems = gems([.red, .blue, .green])

        let outcome = PoopResolver.resolve(in: &session)

        XCTAssertEqual(outcome, .noPoop)
        XCTAssertEqual(session.cups[2].gems.count, 3)
        XCTAssertTrue(session.discardPile.isEmpty)
    }

    // MARK: - Single cup discard

    func testCupWithOneBlackGemMovesAllGemsToDiscardPile() {
        let black = Gem(kind: .black)
        var session = makePlayingSession()
        session.cups[4].gems = [black]

        let outcome = PoopResolver.resolve(in: &session)

        XCTAssertEqual(
            outcome,
            .discardedCups([DiscardedPoopCup(cupIndex: 4, discardedCount: 1)])
        )
        XCTAssertTrue(session.cups[4].gems.isEmpty)
        XCTAssertEqual(session.discardPile.count, 1)
        XCTAssertEqual(session.discardPile.first?.id, black.id)
    }

    func testCupWithBlackAndOtherGemsIsFullyCleared() {
        let red = Gem(kind: .red)
        let gold = Gem(kind: .gold)
        let black = Gem(kind: .black)
        var session = makePlayingSession()
        session.cups[3].gems = [red, black, gold]

        _ = PoopResolver.resolve(in: &session)

        XCTAssertTrue(session.cups[3].gems.isEmpty)
        XCTAssertEqual(session.discardPile.count, 3)
        XCTAssertEqual(Set(session.discardPile.map(\.id)), Set([red.id, black.id, gold.id]))
    }

    func testCupWithMultipleBlackGemsIsDiscardedOnce() {
        var session = makePlayingSession()
        session.cups[5].gems = gems([.black, .black, .yellow])

        let outcome = PoopResolver.resolve(in: &session)

        XCTAssertEqual(
            outcome,
            .discardedCups([DiscardedPoopCup(cupIndex: 5, discardedCount: 3)])
        )
        XCTAssertTrue(session.cups[5].gems.isEmpty)
        XCTAssertEqual(session.discardPile.count, 3)
        XCTAssertEqual(session.discardPile.filter { $0.kind == .black }.count, 2)
    }

    // MARK: - Multiple cups

    func testMultipleCupsWithBlackGemsAreAllDiscarded() {
        var session = makePlayingSession()
        session.cups[1].gems = gems([.black, .red])
        session.cups[6].gems = gems([.blue, .black])

        let outcome = PoopResolver.resolve(in: &session)

        XCTAssertEqual(outcome, .discardedCups([
            DiscardedPoopCup(cupIndex: 1, discardedCount: 2),
            DiscardedPoopCup(cupIndex: 6, discardedCount: 2),
        ]))
        XCTAssertTrue(session.cups[1].gems.isEmpty)
        XCTAssertTrue(session.cups[6].gems.isEmpty)
        XCTAssertEqual(session.discardPile.count, 4)
    }

    func testCompletedCupsWithBlackGemsAreSkipped() {
        var session = makePlayingSession()
        markCompleted(&session, cupIndex: 2)
        session.cups[2].gems = gems([.black, .red])
        session.cups[3].gems = gems([.black])

        _ = PoopResolver.resolve(in: &session)

        XCTAssertEqual(session.cups[2].gems.count, 2)
        XCTAssertTrue(session.cups[3].gems.isEmpty)
        XCTAssertEqual(session.discardPile.count, 1)
    }

    func testPotOfGoldContentsDiscardedWhenPotContainsBlackGem() {
        let potIndex = GameSetup.potOfGoldCupIndex
        let gold = Gem(kind: .gold)
        var session = makePlayingSession()
        session.cups[potIndex].gems = [gold, Gem(kind: .black)]

        _ = PoopResolver.resolve(in: &session)

        XCTAssertTrue(session.cups[potIndex].gems.isEmpty)
        XCTAssertEqual(session.discardPile.count, 2)
        XCTAssertTrue(session.discardPile.contains(where: { $0.id == gold.id }))
    }

    // MARK: - Side effects

    func testPoopResolutionDoesNotCompleteCups() {
        var session = makePlayingSession()
        session.cups[2].gems = gems(Array(repeating: .red, count: 5) + [.black])

        _ = PoopResolver.resolve(in: &session)

        XCTAssertNil(session.cups[2].completion)
        XCTAssertFalse(session.cups[2].isCompleted)
    }

    func testPoopResolutionDiscardsEntireAffectedCupWithoutMovingGoldToPot() {
        let potIndex = GameSetup.potOfGoldCupIndex
        var session = makePlayingSession()
        session.cups[2].gems = gems([.gold, .black, .red])
        session.cups[potIndex].gems = gems([.yellow])

        _ = PoopResolver.resolve(in: &session)

        XCTAssertTrue(session.cups[2].gems.isEmpty)
        XCTAssertEqual(session.cups[potIndex].gems.count, 1)
        XCTAssertEqual(session.cups[potIndex].gems.first?.kind, .yellow)
        XCTAssertEqual(session.discardPile.count, 3)
        XCTAssertTrue(session.discardPile.contains(where: { $0.kind == .gold }))
    }

    // MARK: - End-of-turn ordering

    func testEndOfTurnResolverRunsPoopBeforePendingScoreDetection() {
        var session = makePlayingSession()
        session.cups[2].gems = gems(Array(repeating: .red, count: 5))
        session.cups[3].gems = gems(Array(repeating: .blue, count: 5) + [.black])

        EndOfTurnResolver.resolveAfterPlacementEnds(session: &session)

        XCTAssertEqual(session.pendingScoreChoices.count, 1)
        XCTAssertEqual(session.pendingScoreChoices.first?.cupIndex, 2)
        XCTAssertTrue(session.cups[3].gems.isEmpty)
    }
}
