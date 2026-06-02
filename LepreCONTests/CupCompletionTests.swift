//
// CupCompletionTests.swift
// LepreCONTests
//
// Tests for completed cup/lane domain modeling.
//

import XCTest
@testable import LepreCON

final class CupCompletionTests: XCTestCase {

    private func completion(
        scoredColor: GemKind = .blue,
        wasMatchingCupColor: Bool = false,
        goodCount: Int = 5,
        passCount: Int = 0,
        blemishCount: Int = 0,
        adjustedGoodCount: Int = 5
    ) -> CupCompletion {
        CupCompletion(
            scoredColor: scoredColor,
            wasMatchingCupColor: wasMatchingCupColor,
            goodCount: goodCount,
            passCount: passCount,
            blemishCount: blemishCount,
            adjustedGoodCount: adjustedGoodCount
        )
    }

    func testNewCupStartsWithoutCompletion() {
        let cup = Cup(color: .red)

        XCTAssertNil(cup.completion)
        XCTAssertFalse(cup.isCompleted)
    }

    func testCupWithCompletionReportsIsCompleted() {
        let cup = Cup(color: .red, completion: completion())

        XCTAssertNotNil(cup.completion)
        XCTAssertTrue(cup.isCompleted)
    }

    func testCompletedColoredCupKeepsOriginalColorAndStoresScoredColor() {
        let cup = Cup(
            color: .red,
            completion: completion(scoredColor: .blue, wasMatchingCupColor: false)
        )

        XCTAssertEqual(cup.color, .red)
        XCTAssertEqual(cup.completion?.scoredColor, .blue)
    }

    func testRedCupCanStoreBlueCompletionWithNonMatchingCupColor() {
        let cup = Cup(
            color: .red,
            completion: completion(scoredColor: .blue, wasMatchingCupColor: false)
        )

        XCTAssertEqual(cup.color, .red)
        XCTAssertEqual(cup.completion?.scoredColor, .blue)
        XCTAssertEqual(cup.completion?.wasMatchingCupColor, false)
    }

    func testBlueCupCanStoreBlueCompletionWithMatchingCupColor() {
        let cup = Cup(
            color: .blue,
            completion: completion(scoredColor: .blue, wasMatchingCupColor: true)
        )

        XCTAssertEqual(cup.color, .blue)
        XCTAssertEqual(cup.completion?.scoredColor, .blue)
        XCTAssertEqual(cup.completion?.wasMatchingCupColor, true)
    }

    func testWhiteCloudCupCanStoreBlueCompletionWithNonMatchingCupColor() {
        let cup = Cup(
            color: .white,
            completion: completion(scoredColor: .blue, wasMatchingCupColor: false)
        )

        XCTAssertEqual(cup.color, .white)
        XCTAssertEqual(cup.completion?.scoredColor, .blue)
        XCTAssertEqual(cup.completion?.wasMatchingCupColor, false)
    }
}
