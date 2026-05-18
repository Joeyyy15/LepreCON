//
// DomainModelsTests.swift
// LepreCONTests
//
// Basic tests for core domain model properties.
//

import XCTest
@testable import LepreCON

final class DomainModelsTests: XCTestCase {

    func testCupStartsEmptyByDefault() {
        let cup = Cup(color: .red)

        XCTAssertTrue(cup.gems.isEmpty)
    }

    func testPlayerStoresName() {
        let player = Player(name: "Alex")

        XCTAssertEqual(player.name, "Alex")
    }

    func testGemStoresKind() {
        let gem = Gem(kind: .gold)

        XCTAssertEqual(gem.kind, .gold)
    }
}
