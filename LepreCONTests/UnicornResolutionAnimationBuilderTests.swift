//
// UnicornResolutionAnimationBuilderTests.swift
// LepreCONTests
//

import XCTest
@testable import LepreCON

final class UnicornResolutionAnimationBuilderTests: XCTestCase {

    func testBuildsCalmScriptFromCalmEvent() {
        let script = UnicornResolutionAnimationBuilder.script(
            from: [.unicornCalmed(cupIndex: 4)]
        )
        XCTAssertEqual(script?.startCupIndex, 4)
        XCTAssertEqual(script?.steps, [.calmAtCup(cupIndex: 4)])
    }

    func testBuildsGemStepsFromExplosionEvents() {
        let events: [TurnResolutionEvent] = [
            .unicornExplosionStarted(fromCupIndex: 2),
            .unicornExplosionStep(gemKind: .red, fromCupIndex: 2, toCupIndex: 3),
            .unicornExplosionStep(gemKind: .blue, fromCupIndex: 2, toCupIndex: 5),
            .unicornMoved(toCupIndex: 5)
        ]
        let script = UnicornResolutionAnimationBuilder.script(from: events)
        XCTAssertEqual(script?.startCupIndex, 2)
        XCTAssertEqual(script?.steps.count, 2)
        XCTAssertEqual(
            script?.steps,
            [
                .carryGemToCup(gemKind: .red, toCupIndex: 3),
                .carryGemToCup(gemKind: .blue, toCupIndex: 5)
            ]
        )
    }

    func testReturnsNilWhenNoUnicornEvents() {
        XCTAssertNil(
            UnicornResolutionAnimationBuilder.script(
                from: [.poopResolved]
            )
        )
    }
}
