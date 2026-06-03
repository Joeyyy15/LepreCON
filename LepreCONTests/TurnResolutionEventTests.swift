//
// TurnResolutionEventTests.swift
// LepreCONTests
//
// Verifies unicorn/poop resolution records lightweight events for UI feedback.
//

import XCTest
@testable import LepreCON

final class TurnResolutionEventTests: XCTestCase {

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

    private func explosionSteps(in events: [TurnResolutionEvent]) -> [TurnResolutionEvent] {
        events.filter {
            if case .unicornExplosionStep = $0 { return true }
            return false
        }
    }

    // MARK: - Unicorn

    func testUnicornExplosionRecordsOneEventPerMovedGem() {
        var session = makePlayingSession()
        placeUnicorn(on: 2, in: &session)
        session.cups[2].gems = gems([.red, .blue, .green])

        UnicornResolver.resolve(in: &session)

        XCTAssertEqual(explosionSteps(in: session.recentResolutionEvents).count, 3)
        XCTAssertTrue(session.recentResolutionEvents.contains {
            if case .unicornExplosionStarted(fromCupIndex: 2) = $0 { return true }
            return false
        })
        XCTAssertTrue(session.recentResolutionEvents.contains {
            if case .unicornMoved(toCupIndex: 5) = $0 { return true }
            return false
        })
    }

    func testUnicornCalmRecordsCalmEvent() {
        var session = makePlayingSession()
        placeUnicorn(on: 4, in: &session)
        session.cups[4].gems = gems([.white, .yellow])

        UnicornResolver.resolve(in: &session)

        XCTAssertEqual(session.recentResolutionEvents, [.unicornCalmed(cupIndex: 4)])
    }

    // MARK: - Poop

    func testPoopDiscardRecordsAffectedCupAndDiscardedGems() {
        let red = Gem(kind: .red)
        let gold = Gem(kind: .gold)
        let black = Gem(kind: .black)
        var session = makePlayingSession()
        session.cups[3].gems = [red, black, gold]

        PoopResolver.resolve(in: &session)

        XCTAssertEqual(session.recentResolutionEvents.count, 2)
        guard case .poopDiscardedCup(let cupIndex, let discarded) = session.recentResolutionEvents.first else {
            return XCTFail("Expected poop discard event")
        }
        XCTAssertEqual(cupIndex, 3)
        XCTAssertEqual(Set(discarded.map(\.id)), Set([red.id, gold.id, black.id]))
        XCTAssertEqual(session.recentResolutionEvents.last, .poopResolved)
    }

    func testMultiplePoopCupsRecordMultipleDiscardEvents() {
        var session = makePlayingSession()
        session.cups[1].gems = gems([.black, .red])
        session.cups[6].gems = gems([.blue, .black])

        PoopResolver.resolve(in: &session)

        let discardEvents = session.recentResolutionEvents.compactMap { event -> Int? in
            if case .poopDiscardedCup(let cupIndex, _) = event { return cupIndex }
            return nil
        }
        XCTAssertEqual(discardEvents, [1, 6])
        XCTAssertTrue(session.recentResolutionEvents.contains(.poopResolved))
    }

    // MARK: - Lifecycle

    func testEndOfTurnReplacesEventsBeforeRecordingNewOnes() {
        var session = makePlayingSession()
        session.recentResolutionEvents = [.unicornCalmed(cupIndex: 0)]
        placeUnicorn(on: 5, in: &session)
        session.cups[5].gems = gems([.white])

        EndOfTurnResolver.resolveAfterPlacementEnds(session: &session)

        XCTAssertEqual(session.recentResolutionEvents, [.unicornCalmed(cupIndex: 5)])
    }

    func testBeginTurnClearsResolutionEvents() {
        var session = makePlayingSession()
        session.currentRoll = 1
        session.isTurnPlacementComplete = true
        session.recentResolutionEvents = [.poopResolved]
        session.gemsInBag = [Gem(kind: .green)]

        _ = GameTurnEngine.beginTurn(session: &session, roll: 2)

        XCTAssertTrue(session.recentResolutionEvents.isEmpty)
    }

    func testFullEndOfTurnRecordsUnicornThenPoopEventsInOrder() {
        var session = makePlayingSession()
        placeUnicorn(on: 2, in: &session)
        session.cups[2].gems = gems([.red, .blue])
        session.cups[3].gems = gems([.black, .green])
        session.isTurnPlacementComplete = true

        EndOfTurnResolver.resolveAfterPlacementEnds(session: &session)

        XCTAssertTrue(session.recentResolutionEvents.first?.isUnicornExplosionStarted == true)
        XCTAssertTrue(session.recentResolutionEvents.contains {
            if case .poopDiscardedCup(cupIndex: 3, _) = $0 { return true }
            return false
        })
        XCTAssertEqual(session.recentResolutionEvents.last, .poopResolved)
    }
}

private extension TurnResolutionEvent {
    var isUnicornExplosionStarted: Bool {
        if case .unicornExplosionStarted = self { return true }
        return false
    }
}
