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

    private func gemsPlacedOnBoard(in session: GameSession) -> [Gem] {
        session.cups.flatMap(\.gems)
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

    // MARK: - White gem awaits player decision

    func testWhiteGemInUnicornCupDoesNotAutoCalmOnResolve() {
        let white = Gem(kind: .white)
        let red = Gem(kind: .red)
        var session = makePlayingSession()
        placeUnicorn(on: 3, in: &session)
        session.cups[3].gems = [white, red]

        let outcome = UnicornResolver.resolve(in: &session)

        XCTAssertEqual(outcome, .awaitingPlayerDecision(cupIndex: 3))
        XCTAssertEqual(session.cups[3].gems.map(\.id), [white.id, red.id])
        XCTAssertTrue(session.discardPile.isEmpty)
        XCTAssertEqual(session.unicornCupIndex, 3)
        XCTAssertTrue(session.recentResolutionEvents.isEmpty)
    }

    func testCalmDiscardsExactlyOneWhiteAndLeavesOtherGems() {
        let white = Gem(kind: .white)
        let red = Gem(kind: .red)
        let blue = Gem(kind: .blue)
        var session = makePlayingSession()
        placeUnicorn(on: 4, in: &session)
        session.cups[4].gems = [white, red, blue]

        let outcome = UnicornResolver.calm(in: &session)

        XCTAssertEqual(outcome, .calmedByWhite(cupIndex: 4))
        XCTAssertEqual(session.discardPile.map(\.id), [white.id])
        XCTAssertEqual(session.cups[4].gems.map(\.id), [red.id, blue.id])
        XCTAssertEqual(session.unicornCupIndex, 4)
    }

    func testCalmWithOnlyWhiteEmptiesUnicornCupAndLeavesUnicorn() {
        let white = Gem(kind: .white)
        var session = makePlayingSession()
        placeUnicorn(on: 3, in: &session)
        session.cups[3].gems = [white]

        let outcome = UnicornResolver.calm(in: &session)

        XCTAssertEqual(outcome, .calmedByWhite(cupIndex: 3))
        XCTAssertEqual(session.discardPile.map(\.kind), [.white])
        XCTAssertTrue(session.cups[3].gems.isEmpty)
        XCTAssertEqual(session.unicornCupIndex, 3)
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

        _ = UnicornResolver.calm(in: &session)

        XCTAssertEqual(session.unicornCupIndex, 5)
        XCTAssertEqual(session.unicornCupID, originalCupID)
    }

    func testExplodeCanRunEvenWhenWhiteGemIsPresent() {
        let white = Gem(kind: .white)
        let red = Gem(kind: .red)
        var session = makePlayingSession()
        placeUnicorn(on: 2, in: &session)
        session.cups[2].gems = [white, red]

        let outcome = UnicornResolver.explode(in: &session)

        XCTAssertEqual(outcome, .exploded(fromCupIndex: 2, finalCupIndex: 4))
        XCTAssertTrue(session.cups[2].gems.isEmpty)
        XCTAssertEqual(session.cups[3].gems.map(\.id), [white.id])
        XCTAssertEqual(session.cups[4].gems.map(\.id), [red.id])
        XCTAssertEqual(session.unicornCupIndex, 4)
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

    // MARK: - Unicorn-spread circuit discard

    func testSpreadShorterThanOneCircuitDoesNotDiscard() {
        let spreadGems = gems([.red, .blue, .green])
        var session = makePlayingSession()
        placeUnicorn(on: 2, in: &session)
        session.cups[2].gems = spreadGems

        _ = UnicornResolver.resolve(in: &session)

        XCTAssertTrue(session.discardPile.isEmpty)
        XCTAssertEqual(session.cups[3].gems.map(\.id), [spreadGems[0].id])
        XCTAssertEqual(session.cups[4].gems.map(\.id), [spreadGems[1].id])
        XCTAssertEqual(session.cups[5].gems.map(\.id), [spreadGems[2].id])
    }

    func testExactlyOneFullCircuitPlacesEveryGemAndDoesNotDiscard() {
        var session = makePlayingSession()
        placeUnicorn(on: 0, in: &session)
        let circuitLength = GameTurnEngine.availablePlacementCupCount(in: session)
        XCTAssertEqual(circuitLength, 11)
        let spreadGems = gems(Array(repeating: .red, count: circuitLength))
        session.cups[0].gems = spreadGems

        _ = UnicornResolver.resolve(in: &session)

        XCTAssertTrue(session.discardPile.isEmpty)
        XCTAssertEqual(gemsPlacedOnBoard(in: session).count, circuitLength)
        XCTAssertEqual(Set(gemsPlacedOnBoard(in: session).map(\.id)), Set(spreadGems.map(\.id)))
        XCTAssertEqual(session.unicornCupIndex, 0)
    }

    func testOneFullCircuitPlusOneGemDiscardsTheExtraGem() {
        var session = makePlayingSession()
        placeUnicorn(on: 0, in: &session)
        let circuitLength = GameTurnEngine.availablePlacementCupCount(in: session)
        let discarded = Gem(kind: .gold)
        let spreadGems = gems(Array(repeating: .red, count: circuitLength)) + [discarded]
        session.cups[0].gems = spreadGems

        _ = UnicornResolver.resolve(in: &session)

        XCTAssertEqual(session.discardPile.map(\.id), [discarded.id])
        XCTAssertFalse(session.cups.contains { cup in cup.gems.contains(where: { $0.id == discarded.id }) })
        XCTAssertEqual(gemsPlacedOnBoard(in: session).count, circuitLength)
        XCTAssertEqual(session.unicornCupIndex, 0)
        XCTAssertTrue(session.recentResolutionEvents.contains {
            if case .unicornExplosionDiscarded(gemKind: .gold) = $0 { return true }
            return false
        })
    }

    func testOneFullCircuitPlusMultipleGemsDiscardsOnceThenContinuesClockwise() {
        var session = makePlayingSession()
        placeUnicorn(on: 0, in: &session)
        let circuitLength = GameTurnEngine.availablePlacementCupCount(in: session)
        let discarded = Gem(kind: .pink)
        let extra = Gem(kind: .blue)
        let spreadGems = gems(Array(repeating: .red, count: circuitLength)) + [discarded, extra]
        session.cups[0].gems = spreadGems

        _ = UnicornResolver.resolve(in: &session)

        XCTAssertEqual(session.discardPile.map(\.id), [discarded.id])
        XCTAssertEqual(session.cups[1].gems.last?.id, extra.id)
        XCTAssertEqual(session.unicornCupIndex, 1)
        XCTAssertEqual(gemsPlacedOnBoard(in: session).count, circuitLength + 1)
    }

    func testTwoFullCircuitsProduceTwoAutomaticDiscards() {
        var session = makePlayingSession()
        for index in 3...10 {
            markCompleted(&session, cupIndex: index)
        }
        placeUnicorn(on: 0, in: &session)
        XCTAssertEqual(GameTurnEngine.availablePlacementCupCount(in: session), 3)

        let firstDiscard = Gem(kind: .gold)
        let secondDiscard = Gem(kind: .pink)
        let spreadGems = [
            Gem(kind: .red), Gem(kind: .blue), Gem(kind: .green),
            firstDiscard,
            Gem(kind: .orange), Gem(kind: .yellow), Gem(kind: .purple),
            secondDiscard
        ]
        session.cups[0].gems = spreadGems

        _ = UnicornResolver.resolve(in: &session)

        XCTAssertEqual(session.discardPile.map(\.id), [firstDiscard.id, secondDiscard.id])
        XCTAssertEqual(session.cups[1].gems.map(\.kind), [.red, .orange])
        XCTAssertEqual(session.cups[2].gems.map(\.kind), [.blue, .yellow])
        XCTAssertEqual(session.cups[0].gems.map(\.kind), [.green, .purple])
        XCTAssertEqual(session.unicornCupIndex, 0)
    }

    func testCompletedCupsShortenTheUnicornCircuit() {
        var session = makePlayingSession()
        markCompleted(&session, cupIndex: 2)
        markCompleted(&session, cupIndex: 3)
        markCompleted(&session, cupIndex: 4)
        placeUnicorn(on: 0, in: &session)
        let circuitLength = GameTurnEngine.availablePlacementCupCount(in: session)
        XCTAssertEqual(circuitLength, 8)

        let discarded = Gem(kind: .gold)
        session.cups[0].gems = gems(Array(repeating: .red, count: circuitLength)) + [discarded]

        _ = UnicornResolver.resolve(in: &session)

        XCTAssertEqual(session.discardPile.map(\.id), [discarded.id])
        XCTAssertTrue(session.cups[2].gems.isEmpty)
        XCTAssertTrue(session.cups[3].gems.isEmpty)
        XCTAssertTrue(session.cups[4].gems.isEmpty)
        XCTAssertEqual(gemsPlacedOnBoard(in: session).count, circuitLength)
    }

    func testPotOfGoldCountsTowardTheUnicornCircuit() {
        var session = makePlayingSession()
        for index in 0...8 {
            markCompleted(&session, cupIndex: index)
        }
        placeUnicorn(on: 9, in: &session)
        XCTAssertEqual(GameTurnEngine.availablePlacementCupCount(in: session), 2)

        let first = Gem(kind: .red)
        let second = Gem(kind: .blue)
        let discarded = Gem(kind: .gold)
        session.cups[9].gems = [first, second, discarded]

        _ = UnicornResolver.resolve(in: &session)

        let potIndex = GameSetup.potOfGoldCupIndex
        XCTAssertEqual(session.cups[potIndex].gems.map(\.id), [first.id])
        XCTAssertEqual(session.cups[9].gems.map(\.id), [second.id])
        XCTAssertEqual(session.discardPile.map(\.id), [discarded.id])
        XCTAssertEqual(session.unicornCupIndex, 9)
    }

    func testAutomaticUnicornDiscardPreservesGemIdentity() {
        var session = makePlayingSession()
        placeUnicorn(on: 0, in: &session)
        let circuitLength = GameTurnEngine.availablePlacementCupCount(in: session)
        let discarded = Gem(kind: .clear)
        session.cups[0].gems = gems(Array(repeating: .red, count: circuitLength)) + [discarded]
        let existingDiscard = Gem(kind: .yellow)
        session.discardPile = [existingDiscard]

        _ = UnicornResolver.resolve(in: &session)

        XCTAssertEqual(session.discardPile.map(\.id), [existingDiscard.id, discarded.id])
        XCTAssertEqual(session.discardPile.last?.id, discarded.id)
        XCTAssertEqual(Set(session.discardPile.map(\.id)).count, 2)
    }

    func testBlackGemCanBeAutomaticallyDiscardedByUnicornSpread() {
        var session = makePlayingSession()
        for index in 2...10 {
            markCompleted(&session, cupIndex: index)
        }
        placeUnicorn(on: 0, in: &session)
        XCTAssertEqual(GameTurnEngine.availablePlacementCupCount(in: session), 2)

        let red = Gem(kind: .red)
        let blue = Gem(kind: .blue)
        let poop = Gem(kind: .black)
        session.cups[0].gems = [red, blue, poop]

        _ = UnicornResolver.resolve(in: &session)

        XCTAssertEqual(session.discardPile.map(\.id), [poop.id])
        XCTAssertFalse(session.cups.contains { $0.gems.contains(where: { $0.id == poop.id }) })
        XCTAssertEqual(session.unicornCupIndex, 0)
    }

    func testUnicornSpreadDoesNotChangePlayerRotationProgress() {
        var session = makePlayingSession()
        placeUnicorn(on: 2, in: &session)
        session.cups[2].gems = gems(Array(repeating: .red, count: 12))
        session.placementsCompletedInCurrentRotation = 4
        session.nextPlacementCupIndex = 3
        session.currentRoll = 5
        session.isTurnPlacementComplete = false
        session.gemsInHand = [Gem(kind: .orange)]
        let destinationBefore = GameTurnEngine.currentPlacementDestination(in: session)

        _ = UnicornResolver.resolve(in: &session)

        XCTAssertEqual(session.placementsCompletedInCurrentRotation, 4)
        XCTAssertEqual(GameTurnEngine.currentPlacementDestination(in: session), destinationBefore)
        XCTAssertFalse(GameTurnEngine.isDiscardRequired(in: session))
        XCTAssertEqual(session.nextPlacementCupIndex, 3)
    }

    func testUnicornEndsOnLastCupThatReceivedASpreadGemAfterDiscard() {
        var session = makePlayingSession()
        placeUnicorn(on: 0, in: &session)
        let circuitLength = GameTurnEngine.availablePlacementCupCount(in: session)
        let discarded = Gem(kind: .gold)
        session.cups[0].gems = gems(Array(repeating: .red, count: circuitLength)) + [discarded]

        let outcome = UnicornResolver.resolve(in: &session)

        XCTAssertEqual(outcome, .exploded(fromCupIndex: 0, finalCupIndex: 0))
        XCTAssertEqual(session.unicornCupIndex, 0)
        XCTAssertEqual(session.unicornCupID, session.cups[0].id)
        XCTAssertEqual(session.discardPile.map(\.id), [discarded.id])
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
