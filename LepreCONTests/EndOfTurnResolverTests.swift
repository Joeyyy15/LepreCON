//
// EndOfTurnResolverTests.swift
// LepreCONTests
//
// Behavior tests for ordered end-of-turn resolution.
//

import XCTest
@testable import LepreCON

final class EndOfTurnResolverTests: XCTestCase {

    private func gems(_ kinds: [GemKind]) -> [Gem] {
        kinds.map { Gem(kind: $0) }
    }

    private func makePlayingSession() -> GameSession {
        var session = GameSessionFactory().makeNewGame(playerNames: ["Alex"])
        session.phase = .playing
        for index in session.cups.indices {
            session.cups[index].gems = []
        }
        // Pin unicorn away from cups used in scoring tests (unicorn/poop run before score detection).
        session.unicornCupIndex = 9
        session.unicornCupID = session.cups[9].id
        return session
    }

    func testResolveAfterPlacementEndsRefreshesPendingScoreChoices() {
        var session = makePlayingSession()
        session.cups[2].gems = gems(Array(repeating: .red, count: 5))

        EndOfTurnResolver.resolveAfterPlacementEnds(session: &session)

        XCTAssertEqual(session.pendingScoreChoices.count, 1)
        XCTAssertEqual(session.pendingScoreChoices.first?.cupIndex, 2)
    }

    func testPlacementCompletionProducesPendingChoicesThroughEndOfTurnResolver() {
        var session = makePlayingSession()
        session.cups[2].gems = gems(Array(repeating: .red, count: 5))
        session.cups[0].gems = []
        let handGem = Gem(kind: .green)
        session.gemsInHand = [handGem]
        session.currentRoll = 1
        session.nextPlacementCupIndex = 0

        _ = GameTurnEngine.placeGemInCurrentCup(session: &session, gemID: handGem.id)

        XCTAssertTrue(session.isTurnPlacementComplete)
        XCTAssertEqual(session.pendingScoreChoices.count, 1)
        XCTAssertEqual(session.pendingScoreChoices.first?.cupIndex, 2)
    }

    func testResolveAfterPlacementEndsDoesNotCompleteCupsAutomatically() {
        var session = makePlayingSession()
        session.cups[6].gems = gems(Array(repeating: .blue, count: 5))

        EndOfTurnResolver.resolveAfterPlacementEnds(session: &session)

        XCTAssertNil(session.cups[6].completion)
        XCTAssertFalse(session.cups[6].isCompleted)
    }

    func testResolveAfterPlacementEndsDoesNotMoveGoldToPot() {
        var session = makePlayingSession()
        let potIndex = GameSetup.potOfGoldCupIndex
        session.cups[2].gems = gems(Array(repeating: .red, count: 5))
        session.cups[potIndex].gems = gems([.gold, .yellow])

        EndOfTurnResolver.resolveAfterPlacementEnds(session: &session)

        XCTAssertEqual(session.cups[potIndex].gems.count, 2)
        XCTAssertTrue(session.cups[potIndex].gems.contains(where: { $0.kind == .gold }))
    }
}
