//
// ScoreEvaluatorTests.swift
// LepreCONTests
//
// Tests for pure domain cup scoring evaluation.
//

import XCTest
@testable import LepreCON

final class ScoreEvaluatorTests: XCTestCase {

    // MARK: - Helpers

    private func cup(color: CupColor? = nil, isPotOfGold: Bool = false, kinds: [GemKind]) -> Cup {
        Cup(
            color: color,
            isPotOfGold: isPotOfGold,
            gems: kinds.map { Gem(kind: $0) }
        )
    }

    private func candidate(
        in result: ScoringResult,
        for color: GemKind
    ) -> CupScoreCandidate? {
        result.candidates.first { $0.scoringColor == color }
    }

    // MARK: - Basic scoring

    func testFiveRedGemsInRedCupScoresRed() {
        let cup = cup(color: .red, kinds: Array(repeating: .red, count: 5))
        let result = ScoreEvaluator.evaluate(cup: cup)

        XCTAssertEqual(result.candidates.count, 1)
        let red = candidate(in: result, for: .red)
        XCTAssertEqual(red?.adjustedGoodCount, 5)
        XCTAssertEqual(red?.goodCount, 5)
        XCTAssertEqual(red?.blemishCount, 0)
    }

    func testFiveRedGemsInWhiteCloudCupScoresRed() {
        let cup = cup(color: .white, kinds: Array(repeating: .red, count: 5))
        let result = ScoreEvaluator.evaluate(cup: cup)

        XCTAssertNotNil(candidate(in: result, for: .red))
        XCTAssertEqual(candidate(in: result, for: .red)?.isMatchingCupColor, false)
    }

    func testPotOfGoldCannotScoreEvenWithFiveRedGems() {
        let cup = cup(isPotOfGold: true, kinds: Array(repeating: .red, count: 5))
        let result = ScoreEvaluator.evaluate(cup: cup)

        XCTAssertTrue(result.candidates.isEmpty)
    }

    // MARK: - Gem role counts

    func testClearCountsAsChosenColor() {
        let cup = cup(color: .red, kinds: [.red, .red, .red, .red, .clear])
        let result = ScoreEvaluator.evaluate(cup: cup)

        let red = candidate(in: result, for: .red)
        XCTAssertNotNil(red)
        XCTAssertEqual(red?.goodCount, 5)
        XCTAssertEqual(red?.adjustedGoodCount, 5)
    }

    func testWhiteAndGoldArePassesAndDoNotBlemish() {
        let cup = cup(
            color: .red,
            kinds: [.red, .red, .red, .red, .red, .white, .gold]
        )
        let result = ScoreEvaluator.evaluate(cup: cup)

        let red = candidate(in: result, for: .red)
        XCTAssertNotNil(red)
        XCTAssertEqual(red?.goodCount, 5)
        XCTAssertEqual(red?.passCount, 2)
        XCTAssertEqual(red?.blemishCount, 0)
        XCTAssertEqual(red?.adjustedGoodCount, 5)
    }

    func testOffColorRainbowGemsAndPinkAreBlemishes() {
        // Six reds with three blemishes does not reach the threshold.
        let belowThreshold = cup(
            color: .red,
            kinds: [.red, .red, .red, .red, .red, .red, .green, .purple, .pink]
        )
        XCTAssertTrue(ScoreEvaluator.evaluate(cup: belowThreshold).candidates.isEmpty)

        // Eight reds minus three blemishes still scores — blemishes reduced adjusted count.
        let withBlemishes = cup(
            color: .red,
            kinds: [
                .red, .red, .red, .red, .red, .red, .red, .red,
                .green, .purple, .pink
            ]
        )
        let red = candidate(in: ScoreEvaluator.evaluate(cup: withBlemishes), for: .red)
        XCTAssertNotNil(red)
        XCTAssertEqual(red?.goodCount, 8)
        XCTAssertEqual(red?.blemishCount, 3)
        XCTAssertEqual(red?.adjustedGoodCount, 5)
    }

    func testBlackCountsAsBlemish() {
        let cup = cup(
            color: .red,
            kinds: [.red, .red, .red, .red, .red, .red, .black]
        )
        let result = ScoreEvaluator.evaluate(cup: cup)

        let red = candidate(in: result, for: .red)
        XCTAssertNotNil(red)
        XCTAssertEqual(red?.blemishCount, 1)
        XCTAssertEqual(red?.adjustedGoodCount, 5)
    }

    // MARK: - Rulebook example

    func testRulebookExampleProducesAdjustedGoodCountOfFiveForRed() {
        let cup = cup(
            color: .red,
            kinds: [
                .red, .red, .red, .red, .red, .red, .red,
                .clear,
                .white,
                .gold,
                .green, .green,
                .purple
            ]
        )
        let result = ScoreEvaluator.evaluate(cup: cup)

        let red = candidate(in: result, for: .red)
        XCTAssertNotNil(red)
        XCTAssertEqual(red?.goodCount, 8)
        XCTAssertEqual(red?.passCount, 2)
        XCTAssertEqual(red?.blemishCount, 3)
        XCTAssertEqual(red?.adjustedGoodCount, 5)
    }

    // MARK: - Threshold and matching

    func testCupBelowFiveAdjustedGoodCountDoesNotScore() {
        let cup = cup(color: .red, kinds: [.red, .red, .red, .red, .green])
        let result = ScoreEvaluator.evaluate(cup: cup)

        XCTAssertTrue(result.candidates.isEmpty)
    }

    func testMatchingColoredCupReportsIsMatchingCupColorTrue() {
        let cup = cup(color: .blue, kinds: Array(repeating: .blue, count: 5))
        let result = ScoreEvaluator.evaluate(cup: cup)

        XCTAssertEqual(candidate(in: result, for: .blue)?.isMatchingCupColor, true)
    }

    func testNonMatchingColoredCupReportsIsMatchingCupColorFalse() {
        let cup = cup(color: .red, kinds: Array(repeating: .blue, count: 5))
        let result = ScoreEvaluator.evaluate(cup: cup)

        XCTAssertEqual(candidate(in: result, for: .blue)?.isMatchingCupColor, false)
    }

    func testFiveBlueGemsInRedCupScoresBlueWithNonMatchingCupColor() {
        let cup = cup(color: .red, kinds: Array(repeating: .blue, count: 5))
        let result = ScoreEvaluator.evaluate(cup: cup)

        let blue = candidate(in: result, for: .blue)
        XCTAssertNotNil(blue)
        XCTAssertEqual(blue?.scoringColor, .blue)
        XCTAssertEqual(blue?.isMatchingCupColor, false)
    }

    func testFiveBlueGemsInBlueCupScoresBlueWithMatchingCupColor() {
        let cup = cup(color: .blue, kinds: Array(repeating: .blue, count: 5))
        let result = ScoreEvaluator.evaluate(cup: cup)

        let blue = candidate(in: result, for: .blue)
        XCTAssertNotNil(blue)
        XCTAssertEqual(blue?.isMatchingCupColor, true)
    }

    func testFiveBlueGemsInWhiteCloudCupScoresBlueWithNonMatchingCupColor() {
        let cup = cup(color: .white, kinds: Array(repeating: .blue, count: 5))
        let result = ScoreEvaluator.evaluate(cup: cup)

        let blue = candidate(in: result, for: .blue)
        XCTAssertNotNil(blue)
        XCTAssertEqual(blue?.isMatchingCupColor, false)
    }
}
