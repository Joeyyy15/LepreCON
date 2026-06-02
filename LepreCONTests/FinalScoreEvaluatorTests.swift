//
// FinalScoreEvaluatorTests.swift
// LepreCONTests
//
// Behavior tests for final score and rainbow completion.
//

import XCTest
@testable import LepreCON

final class FinalScoreEvaluatorTests: XCTestCase {

    private func makeSession() -> GameSession {
        GameSession(phase: .playing, cups: GameSetup.makePhysicalCups())
    }

    private func markCompleted(
        _ session: inout GameSession,
        cupIndex: Int,
        scoredColor: GemKind,
        wasMatchingCupColor: Bool
    ) {
        session.cups[cupIndex].completion = CupCompletion(
            scoredColor: scoredColor,
            wasMatchingCupColor: wasMatchingCupColor,
            goodCount: 5,
            passCount: 0,
            blemishCount: 0,
            adjustedGoodCount: 5
        )
    }

    private func evaluate(_ session: GameSession) -> FinalScoreResult {
        FinalScoreEvaluator.evaluate(session: session)
    }

    // MARK: - Color points

    func testNoCompletedCupsGivesZeroColorPointsAndIncompleteRainbow() {
        let result = evaluate(makeSession())

        XCTAssertFalse(result.isRainbowComplete)
        XCTAssertEqual(result.colorPoints, 0)
        XCTAssertEqual(result.completedColorScores.count, 0)
        XCTAssertEqual(result.missingColors.count, 6)
        XCTAssertEqual(result.totalPoints, 0)
        XCTAssertEqual(result.rank, .weeLad)
    }

    func testOneNonMatchingCompletedColorGivesOneColorPoint() {
        var session = makeSession()
        markCompleted(&session, cupIndex: 2, scoredColor: .blue, wasMatchingCupColor: false)

        let result = evaluate(session)

        XCTAssertEqual(result.colorPoints, 1)
        XCTAssertEqual(result.completedColorScores.count, 1)
        XCTAssertEqual(result.completedColorScores.first?.color, .blue)
        XCTAssertEqual(result.completedColorScores.first?.points, 1)
        XCTAssertFalse(result.completedColorScores.first?.wasMatchingCupColor ?? true)
    }

    func testOneMatchingCompletedColorGivesTwoColorPoints() {
        var session = makeSession()
        markCompleted(&session, cupIndex: 6, scoredColor: .blue, wasMatchingCupColor: true)

        let result = evaluate(session)

        XCTAssertEqual(result.colorPoints, 2)
        XCTAssertEqual(result.completedColorScores.first?.points, 2)
        XCTAssertTrue(result.completedColorScores.first?.wasMatchingCupColor ?? false)
    }

    func testWhiteCloudCupCompletionGivesOnePointForThatColor() {
        var session = makeSession()
        markCompleted(&session, cupIndex: 0, scoredColor: .red, wasMatchingCupColor: false)

        let result = evaluate(session)

        XCTAssertEqual(result.colorPoints, 1)
        XCTAssertEqual(result.completedColorScores.first?.cupIndex, 0)
        XCTAssertFalse(result.completedColorScores.first?.wasMatchingCupColor ?? true)
    }

    func testAllSixColorsNonMatchingGivesSixColorPointsAndCompleteRainbow() {
        var session = makeSession()
        let placements: [(Int, GemKind)] = [
            (0, .red), (1, .orange), (2, .yellow), (3, .green), (4, .blue), (5, .purple)
        ]
        for (cupIndex, color) in placements {
            markCompleted(&session, cupIndex: cupIndex, scoredColor: color, wasMatchingCupColor: false)
        }

        let result = evaluate(session)

        XCTAssertTrue(result.isRainbowComplete)
        XCTAssertEqual(result.colorPoints, 6)
        XCTAssertEqual(result.missingColors.count, 0)
    }

    func testAllSixColorsMatchingGivesTwelveColorPoints() {
        var session = makeSession()
        let placements: [(Int, GemKind)] = [
            (2, .red), (3, .orange), (4, .yellow), (5, .green), (6, .blue), (7, .purple)
        ]
        for (cupIndex, color) in placements {
            markCompleted(&session, cupIndex: cupIndex, scoredColor: color, wasMatchingCupColor: true)
        }

        let result = evaluate(session)

        XCTAssertTrue(result.isRainbowComplete)
        XCTAssertEqual(result.colorPoints, 12)
    }

    // MARK: - Gold and unicorn

    func testGoldInPotCountsOnlyWhenRainbowIsComplete() {
        var session = makeSession()
        let potIndex = GameSetup.potOfGoldCupIndex
        session.cups[potIndex].gems = Array(repeating: Gem(kind: .gold), count: 4)
        markAllSixColorsNonMatching(&session)

        let result = evaluate(session)

        XCTAssertTrue(result.isRainbowComplete)
        XCTAssertEqual(result.goldCountInPot, 4)
        XCTAssertEqual(result.goldPoints, 4)
        XCTAssertEqual(result.totalPoints, 6 + 4)
    }

    func testGoldInPotDoesNotCountWhenRainbowIsIncomplete() {
        var session = makeSession()
        let potIndex = GameSetup.potOfGoldCupIndex
        session.cups[potIndex].gems = Array(repeating: Gem(kind: .gold), count: 5)
        markCompleted(&session, cupIndex: 2, scoredColor: .red, wasMatchingCupColor: true)

        let result = evaluate(session)

        XCTAssertFalse(result.isRainbowComplete)
        XCTAssertEqual(result.goldCountInPot, 5)
        XCTAssertEqual(result.goldPoints, 0)
        XCTAssertEqual(result.totalPoints, 2)
    }

    func testUnicornBonusDoesNotCountWhenRainbowIsIncomplete() {
        var session = makeSession()
        session.unicornCaptured = true
        markCompleted(&session, cupIndex: 2, scoredColor: .red, wasMatchingCupColor: true)

        let result = evaluate(session)

        XCTAssertEqual(result.unicornPoints, 0)
    }

    func testUnicornBonusCountsThreeWhenRainbowCompleteAndCaptured() {
        var session = makeSession()
        session.unicornCaptured = true
        markAllSixColorsMatching(&session)

        let result = evaluate(session)

        XCTAssertEqual(result.unicornPoints, 3)
        XCTAssertEqual(result.totalPoints, 12 + 3)
    }

    // MARK: - Missing colors and duplicates

    func testMissingColorsReportedCorrectly() {
        var session = makeSession()
        markCompleted(&session, cupIndex: 2, scoredColor: .red, wasMatchingCupColor: true)
        markCompleted(&session, cupIndex: 6, scoredColor: .blue, wasMatchingCupColor: true)

        let result = evaluate(session)

        XCTAssertEqual(Set(result.missingColors), Set([.orange, .yellow, .green, .purple]))
    }

    func testDuplicateCompletionsForSameColorUseBestScore() {
        var session = makeSession()
        markCompleted(&session, cupIndex: 0, scoredColor: .red, wasMatchingCupColor: false)
        markCompleted(&session, cupIndex: 2, scoredColor: .red, wasMatchingCupColor: true)

        let result = evaluate(session)

        XCTAssertEqual(result.colorPoints, 2)
        XCTAssertEqual(result.completedColorScores.filter { $0.color == .red }.count, 1)
        XCTAssertEqual(result.completedColorScores.first { $0.color == .red }?.points, 2)
        XCTAssertEqual(result.completedColorScores.first { $0.color == .red }?.cupIndex, 2)
    }

    func testPotOfGoldCompletionIsIgnoredForColorScoring() {
        var session = makeSession()
        let potIndex = GameSetup.potOfGoldCupIndex
        markAllSixColorsMatching(&session)
        markCompleted(&session, cupIndex: potIndex, scoredColor: .red, wasMatchingCupColor: true)

        let result = evaluate(session)

        XCTAssertEqual(result.colorPoints, 12)
        XCTAssertEqual(result.completedColorScores.count, 6)
        XCTAssertFalse(result.completedColorScores.contains { $0.cupIndex == potIndex })
    }

    // MARK: - Ranks

    func testRankIsWeeLadForZeroThroughSixPoints() {
        XCTAssertEqual(ScoreRank.from(totalPoints: 0), .weeLad)
        XCTAssertEqual(ScoreRank.from(totalPoints: 6), .weeLad)
    }

    func testRankIsTricksterForSevenThroughTwelvePoints() {
        XCTAssertEqual(ScoreRank.from(totalPoints: 7), .trickster)
        XCTAssertEqual(ScoreRank.from(totalPoints: 12), .trickster)
    }

    func testRankIsFairyForThirteenThroughEighteenPoints() {
        XCTAssertEqual(ScoreRank.from(totalPoints: 13), .fairy)
        XCTAssertEqual(ScoreRank.from(totalPoints: 18), .fairy)
    }

    func testRankIsLuckNorrisForNineteenThroughTwentyFourPoints() {
        XCTAssertEqual(ScoreRank.from(totalPoints: 19), .luckNorris)
        XCTAssertEqual(ScoreRank.from(totalPoints: 24), .luckNorris)
    }

    func testMaximumScoreCanReachTwentyFour() {
        var session = makeSession()
        let potIndex = GameSetup.potOfGoldCupIndex
        session.cups[potIndex].gems = Array(repeating: Gem(kind: .gold), count: 9)
        session.unicornCaptured = true
        markAllSixColorsMatching(&session)

        let result = evaluate(session)

        XCTAssertEqual(result.colorPoints, 12)
        XCTAssertEqual(result.goldPoints, 9)
        XCTAssertEqual(result.unicornPoints, 3)
        XCTAssertEqual(result.totalPoints, 24)
        XCTAssertEqual(result.rank, .luckNorris)
    }

    // MARK: - Game completion

    func testGameCompletionDetectorMatchesRainbowComplete() {
        var session = makeSession()
        markAllSixColorsNonMatching(&session)

        XCTAssertTrue(GameCompletionDetector.isGameComplete(session: session))
    }

    // MARK: - Helpers

    private func markAllSixColorsNonMatching(_ session: inout GameSession) {
        let colors: [GemKind] = [.red, .orange, .yellow, .green, .blue, .purple]
        for (index, color) in colors.enumerated() {
            markCompleted(&session, cupIndex: index, scoredColor: color, wasMatchingCupColor: false)
        }
    }

    private func markAllSixColorsMatching(_ session: inout GameSession) {
        let placements: [(Int, GemKind)] = [
            (2, .red), (3, .orange), (4, .yellow), (5, .green), (6, .blue), (7, .purple)
        ]
        for (cupIndex, color) in placements {
            markCompleted(&session, cupIndex: cupIndex, scoredColor: color, wasMatchingCupColor: true)
        }
    }
}
