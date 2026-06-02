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
        extraPendingCups: [(Int, [GemKind])] = []
    ) -> GameSession {
        var cups = makeBoardCups()
        cups[cupIndex].gems = gems(gemKinds)
        for (index, kinds) in extraPendingCups {
            cups[index].gems = gems(kinds)
        }
        var session = GameSession(phase: .playing, cups: cups)
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
}
