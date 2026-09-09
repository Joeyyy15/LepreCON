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

    private enum ExplosionLanding: Equatable {
        case placed(cupIndex: Int, gemKind: GemKind)
        case discarded(gemKind: GemKind)
    }

    private func explosionLandingSequence(in events: [TurnResolutionEvent]) -> [ExplosionLanding] {
        events.compactMap { event in
            switch event {
            case .unicornExplosionStep(let gemKind, _, let toCupIndex):
                return .placed(cupIndex: toCupIndex, gemKind: gemKind)
            case .unicornExplosionDiscarded(let gemKind):
                return .discarded(gemKind: gemKind)
            default:
                return nil
            }
        }
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

    // MARK: - Unicorn-spread 12-step sequence

    func testSpreadFromOrangeFollowsBoardSequenceThroughDiscardToCloud1() {
        let gems = [
            Gem(kind: .red), Gem(kind: .orange), Gem(kind: .yellow),
            Gem(kind: .green), Gem(kind: .blue), Gem(kind: .purple),
            Gem(kind: .gold), Gem(kind: .pink), Gem(kind: .clear)
        ]
        var session = makePlayingSession()
        placeUnicorn(on: 3, in: &session)
        session.cups[3].gems = gems

        _ = UnicornResolver.resolve(in: &session)

        XCTAssertEqual(session.cups[4].gems.map(\.id), [gems[0].id])
        XCTAssertEqual(session.cups[5].gems.map(\.id), [gems[1].id])
        XCTAssertEqual(session.cups[6].gems.map(\.id), [gems[2].id])
        XCTAssertEqual(session.cups[7].gems.map(\.id), [gems[3].id])
        XCTAssertEqual(session.cups[8].gems.map(\.id), [gems[4].id])
        XCTAssertEqual(session.cups[9].gems.map(\.id), [gems[5].id])
        XCTAssertEqual(session.cups[10].gems.map(\.id), [gems[6].id])
        XCTAssertEqual(session.discardPile.map(\.id), [gems[7].id])
        XCTAssertEqual(session.cups[0].gems.map(\.id), [gems[8].id])
        XCTAssertFalse(session.cups.contains { $0.gems.contains(where: { $0.id == gems[7].id }) })
        XCTAssertEqual(session.unicornCupIndex, 0)
        XCTAssertEqual(
            explosionLandingSequence(in: session.recentResolutionEvents),
            [
                .placed(cupIndex: 4, gemKind: .red),
                .placed(cupIndex: 5, gemKind: .orange),
                .placed(cupIndex: 6, gemKind: .yellow),
                .placed(cupIndex: 7, gemKind: .green),
                .placed(cupIndex: 8, gemKind: .blue),
                .placed(cupIndex: 9, gemKind: .purple),
                .placed(cupIndex: 10, gemKind: .gold),
                .discarded(gemKind: .pink),
                .placed(cupIndex: 0, gemKind: .clear)
            ]
        )
    }

    func testSpreadFromCloud4IsPotThenDiscardThenCloud1ThenCloud2() {
        let gems = [Gem(kind: .red), Gem(kind: .blue), Gem(kind: .green), Gem(kind: .gold)]
        var session = makePlayingSession()
        placeUnicorn(on: 9, in: &session)
        session.cups[9].gems = gems

        _ = UnicornResolver.resolve(in: &session)

        XCTAssertEqual(session.cups[10].gems.map(\.id), [gems[0].id])
        XCTAssertEqual(session.discardPile.map(\.id), [gems[1].id])
        XCTAssertEqual(session.cups[0].gems.map(\.id), [gems[2].id])
        XCTAssertEqual(session.cups[1].gems.map(\.id), [gems[3].id])
        XCTAssertEqual(session.unicornCupIndex, 1)
    }

    func testSpreadFromPotIsDiscardThenCloud1ThenCloud2() {
        let gems = [Gem(kind: .red), Gem(kind: .blue), Gem(kind: .green)]
        var session = makePlayingSession()
        placeUnicorn(on: 10, in: &session)
        session.cups[10].gems = gems

        _ = UnicornResolver.resolve(in: &session)

        XCTAssertTrue(session.cups[10].gems.isEmpty)
        XCTAssertEqual(session.discardPile.map(\.id), [gems[0].id])
        XCTAssertEqual(session.cups[0].gems.map(\.id), [gems[1].id])
        XCTAssertEqual(session.cups[1].gems.map(\.id), [gems[2].id])
        XCTAssertEqual(session.unicornCupIndex, 1)
        XCTAssertEqual(
            explosionLandingSequence(in: session.recentResolutionEvents),
            [
                .discarded(gemKind: .red),
                .placed(cupIndex: 0, gemKind: .blue),
                .placed(cupIndex: 1, gemKind: .green)
            ]
        )
    }

    func testSpreadFromCloud1StartsAtCloud2ThenRedThenOrange() {
        let gems = [Gem(kind: .red), Gem(kind: .blue), Gem(kind: .green)]
        var session = makePlayingSession()
        placeUnicorn(on: 0, in: &session)
        session.cups[0].gems = gems

        _ = UnicornResolver.resolve(in: &session)

        XCTAssertTrue(session.cups[0].gems.isEmpty)
        XCTAssertEqual(session.cups[1].gems.map(\.id), [gems[0].id])
        XCTAssertEqual(session.cups[2].gems.map(\.id), [gems[1].id])
        XCTAssertEqual(session.cups[3].gems.map(\.id), [gems[2].id])
        XCTAssertTrue(session.discardPile.isEmpty)
        XCTAssertEqual(session.unicornCupIndex, 3)
    }

    func testDiscardedSpreadGemKeepsIdentityAndDoesNotMoveUnicorn() {
        let placed = Gem(kind: .red)
        let discarded = Gem(kind: .gold)
        var session = makePlayingSession()
        placeUnicorn(on: 9, in: &session)
        session.cups[9].gems = [placed, discarded]
        let existingDiscard = Gem(kind: .yellow)
        session.discardPile = [existingDiscard]

        _ = UnicornResolver.resolve(in: &session)

        XCTAssertEqual(session.discardPile.map(\.id), [existingDiscard.id, discarded.id])
        XCTAssertFalse(session.cups.contains { $0.gems.contains(where: { $0.id == discarded.id }) })
        XCTAssertEqual(session.unicornCupIndex, 10)
        XCTAssertEqual(session.cups[10].gems.map(\.id), [placed.id])
    }

    func testFinalGemToDiscardLeavesUnicornOnPreviousCupLanding() {
        let placed = Gem(kind: .red)
        let discarded = Gem(kind: .blue)
        var session = makePlayingSession()
        placeUnicorn(on: 9, in: &session)
        session.cups[9].gems = [placed, discarded]

        let outcome = UnicornResolver.resolve(in: &session)

        XCTAssertEqual(outcome, .exploded(fromCupIndex: 9, finalCupIndex: 10))
        XCTAssertEqual(session.unicornCupIndex, 10)
        XCTAssertEqual(session.unicornCupID, session.cups[10].id)
        XCTAssertEqual(session.discardPile.map(\.id), [discarded.id])
    }

    func testEveryPassAfterPotHitsDiscardExactlyOnce() {
        var session = makePlayingSession()
        placeUnicorn(on: 3, in: &session)
        let spreadGems = (0..<20).map { _ in Gem(kind: .red) }
        session.cups[3].gems = spreadGems

        _ = UnicornResolver.resolve(in: &session)

        XCTAssertEqual(session.discardPile.map(\.id), [spreadGems[7].id, spreadGems[19].id])
        XCTAssertEqual(session.unicornCupIndex, 10)
    }

    func testUnicornSpreadDoesNotChangePlayerRotationProgress() {
        var session = makePlayingSession()
        placeUnicorn(on: 7, in: &session)
        session.cups[7].gems = gems([.red, .blue, .green, .gold, .pink])
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

    func testCompletedCupsAreSkippedButDiscardStillFollowsPot() {
        let gem1 = Gem(kind: .red)
        let gem2 = Gem(kind: .gold)
        let gem3 = Gem(kind: .blue)
        var session = makePlayingSession()
        markCompleted(&session, cupIndex: 8)
        markCompleted(&session, cupIndex: 9)
        placeUnicorn(on: 7, in: &session)
        session.cups[7].gems = [gem1, gem2, gem3]

        _ = UnicornResolver.explode(in: &session)

        XCTAssertEqual(session.cups[10].gems.map(\.id), [gem1.id])
        XCTAssertTrue(session.cups[8].gems.isEmpty)
        XCTAssertTrue(session.cups[9].gems.isEmpty)
        XCTAssertEqual(session.discardPile.map(\.id), [gem2.id])
        XCTAssertEqual(session.cups[0].gems.map(\.id), [gem3.id])
        XCTAssertEqual(session.unicornCupIndex, 0)
    }

    func testBlackGemCanBeAutomaticallyDiscardedByUnicornSpread() {
        let red = Gem(kind: .red)
        let poop = Gem(kind: .black)
        var session = makePlayingSession()
        placeUnicorn(on: 9, in: &session)
        session.cups[9].gems = [red, poop]

        _ = UnicornResolver.resolve(in: &session)

        XCTAssertEqual(session.discardPile.map(\.id), [poop.id])
        XCTAssertFalse(session.cups.contains { $0.gems.contains(where: { $0.id == poop.id }) })
        XCTAssertEqual(session.unicornCupIndex, 10)
    }

    func testAutomaticUnicornDiscardAppearsInDiscardDisplayState() {
        let discarded = Gem(kind: .gold)
        var session = makePlayingSession()
        placeUnicorn(on: 9, in: &session)
        session.cups[9].gems = [Gem(kind: .red), discarded]

        _ = UnicornResolver.resolve(in: &session)

        let display = GameBoardDisplayState.from(session: session)
        XCTAssertEqual(display.discardGemCounts.map(\.kind), [.gold])
        XCTAssertEqual(display.discardGemCounts.first?.count, 1)
        XCTAssertFalse(GameTurnEngine.isDiscardRequired(in: session))
        XCTAssertNotEqual(GameTurnEngine.currentPlacementDestination(in: session), .discard)
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
