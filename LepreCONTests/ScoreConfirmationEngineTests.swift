//
// ScoreConfirmationEngineTests.swift
// LepreCONTests
//
// Behavior tests for player-confirmed scoring in the domain layer.
//

import XCTest
@testable import LepreCON

final class ScoreConfirmationEngineTests: XCTestCase {

    private func makeBoardCups() -> [Cup] {
        GameSetup.makePhysicalCups()
    }

    private func gems(_ kinds: [GemKind]) -> [Gem] {
        kinds.map { Gem(kind: $0) }
    }

    private func sessionWithPendingScore(
        cupIndex: Int,
        gemKinds: [GemKind],
        extraPendingCups: [(Int, [GemKind])] = [],
        unicornCupIndex: Int? = nil
    ) -> GameSession {
        var cups = makeBoardCups()
        cups[cupIndex].gems = gems(gemKinds)
        for (index, kinds) in extraPendingCups {
            cups[index].gems = gems(kinds)
        }
        var session = GameSession(phase: .playing, cups: cups)
        if let unicornCupIndex {
            session.unicornCupIndex = unicornCupIndex
            session.unicornCupID = cups[unicornCupIndex].id
        }
        PendingScoreDetector.refreshPendingScoreChoices(in: &session)
        return session
    }

    private func assertFailure(
        _ result: Result<Void, ScoreConfirmationError>,
        equals expected: ScoreConfirmationError,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        switch result {
        case .success:
            XCTFail("Expected failure \(expected)", file: file, line: line)
        case .failure(let error):
            XCTAssertEqual(error, expected, file: file, line: line)
        }
    }

    private func assertSuccess(
        _ result: Result<Void, ScoreConfirmationError>,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        if case .failure(let error) = result {
            XCTFail("Expected success, got \(error)", file: file, line: line)
        }
    }

    // MARK: - Successful confirmation

    func testConfirmingValidPendingScoreMarksCupCompleted() {
        var session = sessionWithPendingScore(cupIndex: 2, gemKinds: Array(repeating: .red, count: 5))

        let result = ScoreConfirmationEngine.confirmScore(session: &session, cupIndex: 2, scoringColor: .red)

        assertSuccess(result)
        XCTAssertTrue(session.cups[2].isCompleted)
    }

    func testConfirmingBlueInRedCupStoresScoredColorAndNonMatchingFlag() {
        var session = sessionWithPendingScore(cupIndex: 2, gemKinds: Array(repeating: .blue, count: 5))

        _ = ScoreConfirmationEngine.confirmScore(session: &session, cupIndex: 2, scoringColor: .blue)

        XCTAssertEqual(session.cups[2].color, .red)
        XCTAssertEqual(session.cups[2].completion?.scoredColor, .blue)
        XCTAssertEqual(session.cups[2].completion?.wasMatchingCupColor, false)
    }

    func testConfirmingBlueInBlueCupStoresMatchingCupColor() {
        var session = sessionWithPendingScore(cupIndex: 6, gemKinds: Array(repeating: .blue, count: 5))

        _ = ScoreConfirmationEngine.confirmScore(session: &session, cupIndex: 6, scoringColor: .blue)

        XCTAssertEqual(session.cups[6].color, .blue)
        XCTAssertEqual(session.cups[6].completion?.scoredColor, .blue)
        XCTAssertEqual(session.cups[6].completion?.wasMatchingCupColor, true)
    }

    func testConfirmingBlueInWhiteCloudCupStoresNonMatchingCupColor() {
        var session = sessionWithPendingScore(cupIndex: 0, gemKinds: Array(repeating: .blue, count: 5))

        _ = ScoreConfirmationEngine.confirmScore(session: &session, cupIndex: 0, scoringColor: .blue)

        XCTAssertEqual(session.cups[0].color, .white)
        XCTAssertEqual(session.cups[0].completion?.scoredColor, .blue)
        XCTAssertEqual(session.cups[0].completion?.wasMatchingCupColor, false)
    }

    func testConfirmingScoreStoresCountsFromSelectedCandidate() {
        let gemKinds: [GemKind] = [
            .red, .red, .red, .red, .red, .red, .red,
            .clear,
            .white,
            .gold,
            .green, .green,
            .purple
        ]
        var session = sessionWithPendingScore(cupIndex: 2, gemKinds: gemKinds)

        _ = ScoreConfirmationEngine.confirmScore(session: &session, cupIndex: 2, scoringColor: .red)

        let completion = session.cups[2].completion
        XCTAssertEqual(completion?.goodCount, 8)
        XCTAssertEqual(completion?.passCount, 2)
        XCTAssertEqual(completion?.blemishCount, 3)
        XCTAssertEqual(completion?.adjustedGoodCount, 5)
    }

    func testGoldInScoredCupMovesToPotOfGold() {
        var session = sessionWithPendingScore(
            cupIndex: 2,
            gemKinds: Array(repeating: .red, count: 5) + [.gold, .gold]
        )
        let potIndex = GameSetup.potOfGoldCupIndex
        let potGoldBefore = session.cups[potIndex].gems.filter { $0.kind == .gold }.count

        _ = ScoreConfirmationEngine.confirmScore(session: &session, cupIndex: 2, scoringColor: .red)

        XCTAssertEqual(session.cups[potIndex].gems.filter { $0.kind == .gold }.count, potGoldBefore + 2)
        XCTAssertFalse(session.cups[2].gems.contains(where: { $0.kind == .gold }))
    }

    func testNonGoldGemsAreClearedFromCompletedCup() {
        var session = sessionWithPendingScore(cupIndex: 2, gemKinds: Array(repeating: .red, count: 5))

        _ = ScoreConfirmationEngine.confirmScore(session: &session, cupIndex: 2, scoringColor: .red)

        XCTAssertTrue(session.cups[2].gems.isEmpty)
    }

    func testCompletedCupNoLongerAppearsInPendingScoreChoices() {
        var session = sessionWithPendingScore(cupIndex: 2, gemKinds: Array(repeating: .red, count: 5))

        _ = ScoreConfirmationEngine.confirmScore(session: &session, cupIndex: 2, scoringColor: .red)

        XCTAssertNil(session.pendingScoreChoices.first { $0.cupIndex == 2 })
    }

    func testConfirmingScoreRefreshesPendingScoreChoicesForRemainingBoard() {
        var session = sessionWithPendingScore(
            cupIndex: 2,
            gemKinds: Array(repeating: .red, count: 5),
            extraPendingCups: [(6, Array(repeating: .blue, count: 5))]
        )

        _ = ScoreConfirmationEngine.confirmScore(session: &session, cupIndex: 2, scoringColor: .red)

        XCTAssertEqual(session.pendingScoreChoices.count, 1)
        XCTAssertEqual(session.pendingScoreChoices.first?.cupIndex, 6)
    }

    func testMultipleCandidatesUsesSelectedColorNotFirstAutomatically() {
        var session = sessionWithPendingScore(cupIndex: 2, gemKinds: Array(repeating: .clear, count: 5))
        let pending = session.pendingScoreChoices.first { $0.cupIndex == 2 }
        XCTAssertGreaterThan(pending?.candidates.count ?? 0, 1)

        _ = ScoreConfirmationEngine.confirmScore(session: &session, cupIndex: 2, scoringColor: .purple)

        XCTAssertEqual(session.cups[2].completion?.scoredColor, .purple)
        XCTAssertNotEqual(session.cups[2].completion?.scoredColor, pending?.candidates.first?.scoringColor)
    }

    // MARK: - Unicorn capture

    func testConfirmingScoreInUnicornCupSetsUnicornCaptured() {
        var session = sessionWithPendingScore(
            cupIndex: 2,
            gemKinds: Array(repeating: .red, count: 5),
            unicornCupIndex: 2
        )

        _ = ScoreConfirmationEngine.confirmScore(session: &session, cupIndex: 2, scoringColor: .red)

        XCTAssertTrue(session.unicornCaptured)
    }

    func testConfirmingScoreInUnicornCupClearsUnicornCupIndex() {
        var session = sessionWithPendingScore(
            cupIndex: 6,
            gemKinds: Array(repeating: .blue, count: 5),
            unicornCupIndex: 6
        )

        _ = ScoreConfirmationEngine.confirmScore(session: &session, cupIndex: 6, scoringColor: .blue)

        XCTAssertNil(session.unicornCupIndex)
    }

    func testConfirmingScoreInUnicornCupClearsUnicornCupID() {
        var session = sessionWithPendingScore(
            cupIndex: 0,
            gemKinds: Array(repeating: .green, count: 5),
            unicornCupIndex: 0
        )
        let originalCupID = session.cups[0].id

        _ = ScoreConfirmationEngine.confirmScore(session: &session, cupIndex: 0, scoringColor: .green)

        XCTAssertNil(session.unicornCupID)
        XCTAssertEqual(session.cups[0].id, originalCupID)
    }

    func testConfirmingScoreInDifferentCupDoesNotCaptureUnicorn() {
        var session = sessionWithPendingScore(
            cupIndex: 2,
            gemKinds: Array(repeating: .red, count: 5),
            unicornCupIndex: 6
        )

        _ = ScoreConfirmationEngine.confirmScore(session: &session, cupIndex: 2, scoringColor: .red)

        XCTAssertFalse(session.unicornCaptured)
        XCTAssertEqual(session.unicornCupIndex, 6)
        XCTAssertEqual(session.unicornCupID, session.cups[6].id)
    }

    func testFailedScoreConfirmationDoesNotCaptureUnicorn() {
        var session = sessionWithPendingScore(
            cupIndex: 2,
            gemKinds: Array(repeating: .red, count: 5),
            unicornCupIndex: 2
        )

        _ = ScoreConfirmationEngine.confirmScore(session: &session, cupIndex: 2, scoringColor: .blue)

        XCTAssertFalse(session.unicornCaptured)
    }

    func testFailedScoreConfirmationDoesNotClearUnicornLocation() {
        var session = sessionWithPendingScore(
            cupIndex: 2,
            gemKinds: Array(repeating: .red, count: 5),
            unicornCupIndex: 2
        )
        let unicornID = session.unicornCupID

        _ = ScoreConfirmationEngine.confirmScore(session: &session, cupIndex: 2, scoringColor: .blue)

        XCTAssertEqual(session.unicornCupIndex, 2)
        XCTAssertEqual(session.unicornCupID, unicornID)
    }

    func testConfirmingScoreInUnicornCupStillCompletesCupNormally() {
        var session = sessionWithPendingScore(
            cupIndex: 2,
            gemKinds: Array(repeating: .red, count: 5),
            unicornCupIndex: 2
        )

        _ = ScoreConfirmationEngine.confirmScore(session: &session, cupIndex: 2, scoringColor: .red)

        XCTAssertTrue(session.cups[2].isCompleted)
        XCTAssertEqual(session.cups[2].completion?.scoredColor, .red)
        XCTAssertTrue(session.cups[2].gems.isEmpty)
    }

    func testCaptureEnablesUnicornBonusWhenRainbowIsComplete() {
        var session = sessionWithPendingScore(
            cupIndex: 2,
            gemKinds: Array(repeating: .red, count: 5),
            unicornCupIndex: 2
        )
        markAllSixColorsMatchingExceptRed(&session)

        _ = ScoreConfirmationEngine.confirmScore(session: &session, cupIndex: 2, scoringColor: .red)

        let result = FinalScoreEvaluator.evaluate(session: session)
        XCTAssertTrue(result.isRainbowComplete)
        XCTAssertTrue(result.unicornCaptured)
        XCTAssertEqual(result.unicornPoints, 3)
    }

    func testCaptureDoesNotGiveUnicornBonusWhenRainbowIsIncomplete() {
        var session = sessionWithPendingScore(
            cupIndex: 2,
            gemKinds: Array(repeating: .red, count: 5),
            unicornCupIndex: 2
        )

        _ = ScoreConfirmationEngine.confirmScore(session: &session, cupIndex: 2, scoringColor: .red)

        let result = FinalScoreEvaluator.evaluate(session: session)
        XCTAssertFalse(result.isRainbowComplete)
        XCTAssertTrue(result.unicornCaptured)
        XCTAssertEqual(result.unicornPoints, 0)
    }

    func testDisplayStateNoLongerMarksUnicornAfterCapture() {
        var session = sessionWithPendingScore(
            cupIndex: 2,
            gemKinds: Array(repeating: .red, count: 5),
            unicornCupIndex: 2
        )

        _ = ScoreConfirmationEngine.confirmScore(session: &session, cupIndex: 2, scoringColor: .red)

        let display = GameBoardDisplayState.from(session: session)
        let unicornCupCount =
            display.rainbowLanes.filter(\.hasUnicorn).count
            + display.bottomRow.filter { $0.cupSlot.hasUnicorn }.count

        XCTAssertEqual(unicornCupCount, 0)
    }

    // MARK: - Errors

    func testInvalidCupIndexReturnsError() {
        var session = sessionWithPendingScore(cupIndex: 2, gemKinds: Array(repeating: .red, count: 5))

        let result = ScoreConfirmationEngine.confirmScore(session: &session, cupIndex: 99, scoringColor: .red)

        assertFailure(result, equals: .invalidCupIndex)
    }

    func testConfirmingCompletedCupReturnsError() {
        var session = sessionWithPendingScore(cupIndex: 2, gemKinds: Array(repeating: .red, count: 5))
        _ = ScoreConfirmationEngine.confirmScore(session: &session, cupIndex: 2, scoringColor: .red)

        let result = ScoreConfirmationEngine.confirmScore(session: &session, cupIndex: 2, scoringColor: .red)

        assertFailure(result, equals: .cupAlreadyCompleted)
    }

    func testConfirmingPotOfGoldReturnsError() {
        var session = GameSession(phase: .playing, cups: makeBoardCups())
        session.pendingScoreChoices = []

        let result = ScoreConfirmationEngine.confirmScore(
            session: &session,
            cupIndex: GameSetup.potOfGoldCupIndex,
            scoringColor: .red
        )

        assertFailure(result, equals: .potOfGoldCannotScore)
    }

    func testCupWithNoPendingScoreChoiceReturnsError() {
        var session = GameSession(phase: .playing, cups: makeBoardCups())
        session.pendingScoreChoices = []

        let result = ScoreConfirmationEngine.confirmScore(session: &session, cupIndex: 2, scoringColor: .red)

        assertFailure(result, equals: .noPendingScoreChoiceForCup)
    }

    func testUnavailableScoringColorReturnsError() {
        var session = sessionWithPendingScore(cupIndex: 2, gemKinds: Array(repeating: .red, count: 5))

        let result = ScoreConfirmationEngine.confirmScore(session: &session, cupIndex: 2, scoringColor: .blue)

        assertFailure(result, equals: .scoringCandidateNotAvailable)
    }

    func testMissingPotOfGoldDoesNotPartiallyMutateScoredCup() {
        var session = sessionWithPendingScore(
            cupIndex: 2,
            gemKinds: Array(repeating: .red, count: 5) + [.gold]
        )
        let gemsBefore = session.cups[2].gems
        let pendingBefore = session.pendingScoreChoices

        session.cups[GameSetup.potOfGoldCupIndex] = Cup(color: .yellow, gems: [])

        let result = ScoreConfirmationEngine.confirmScore(session: &session, cupIndex: 2, scoringColor: .red)

        assertFailure(result, equals: .potOfGoldMissing)
        XCTAssertNil(session.cups[2].completion)
        XCTAssertFalse(session.cups[2].isCompleted)
        XCTAssertEqual(session.cups[2].gems.map(\.id), gemsBefore.map(\.id))
        XCTAssertEqual(session.pendingScoreChoices, pendingBefore)
    }

    // MARK: - Unicorn capture helpers

    private func markAllSixColorsMatchingExceptRed(_ session: inout GameSession) {
        let placements: [(Int, GemKind)] = [
            (3, .orange), (4, .yellow), (5, .green), (6, .blue), (7, .purple)
        ]
        for (cupIndex, color) in placements {
            session.cups[cupIndex].completion = CupCompletion(
                scoredColor: color,
                wasMatchingCupColor: true,
                goodCount: 5,
                passCount: 0,
                blemishCount: 0,
                adjustedGoodCount: 5
            )
        }
    }
}
