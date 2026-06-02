//
// GameSetupTests.swift
// LepreCONTests
//
// Tests for rulebook gem counts, bag contents, and physical setup placement.
//

import XCTest
@testable import LepreCON

final class GameSetupTests: XCTestCase {

  func testStandardGemCountsMatchRulebook() {
    XCTAssertEqual(GameSetup.standardGemCounts[.red], 12)
    XCTAssertEqual(GameSetup.standardGemCounts[.orange], 12)
    XCTAssertEqual(GameSetup.standardGemCounts[.yellow], 12)
    XCTAssertEqual(GameSetup.standardGemCounts[.green], 12)
    XCTAssertEqual(GameSetup.standardGemCounts[.blue], 12)
    XCTAssertEqual(GameSetup.standardGemCounts[.purple], 12)
    XCTAssertEqual(GameSetup.standardGemCounts[.gold], 9)
    XCTAssertEqual(GameSetup.standardGemCounts[.black], 3)
    XCTAssertEqual(GameSetup.standardGemCounts[.white], 3)
    XCTAssertEqual(GameSetup.standardGemCounts[.clear], 3)
    XCTAssertEqual(GameSetup.standardGemCounts[.pink], 3)
  }

  func testStandardGemCountsSumToTotalGemCount() {
    let sum = GameSetup.standardGemCounts.values.reduce(0, +)
    XCTAssertEqual(sum, GameSetup.totalGemCount)
    XCTAssertEqual(sum, 93)
  }

  func testWhiteAndClearAreSeparateGemKinds() {
    XCTAssertNotEqual(GemKind.white, GemKind.clear)
    XCTAssertTrue(GemKind.allCases.contains(.white))
    XCTAssertTrue(GemKind.allCases.contains(.clear))
  }

  func testMakeFullGemBagIncludesWhiteAndClearGems() {
    let bag = GameSetup.makeFullGemBag()

    XCTAssertEqual(bag.filter { $0.kind == .white }.count, 3)
    XCTAssertEqual(bag.filter { $0.kind == .clear }.count, 3)
    XCTAssertEqual(bag.count, GameSetup.totalGemCount)
  }

  func testMakeFullGemBagHasRulebookCountForEachKind() {
    let bag = GameSetup.makeFullGemBag()

    for kind in GemKind.allCases {
      let expected = GameSetup.standardGemCounts[kind, default: 0]
      let actual = bag.filter { $0.kind == kind }.count
      XCTAssertEqual(actual, expected, "Expected \(expected) \(kind) gems, found \(actual)")
    }
  }

  func testPlaceSetupGemsInCupsExcludesBlackGemsFromCups() {
    var cups = GameSetup.makePhysicalCups()
    var bag = GameSetup.makeFullGemBag()

    GameSetup.placeSetupGemsInCups(cups: &cups, gemsInBag: &bag)

    let gemsInCups = cups.flatMap(\.gems)
    XCTAssertEqual(gemsInCups.count, cups.count)
    XCTAssertFalse(gemsInCups.contains(where: { $0.kind == .black }))
  }

  func testPlaceSetupGemsInCupsLeavesBlackGemsInBag() {
    var cups = GameSetup.makePhysicalCups()
    var bag = GameSetup.makeFullGemBag()

    GameSetup.placeSetupGemsInCups(cups: &cups, gemsInBag: &bag)

    XCTAssertEqual(bag.filter { $0.kind == .black }.count, 3)
  }

  func testPlaceSetupGemsInCupsPlacesOneNonBlackGemPerCup() {
    var cups = GameSetup.makePhysicalCups()
    var bag = GameSetup.makeFullGemBag()

    GameSetup.placeSetupGemsInCups(cups: &cups, gemsInBag: &bag)

    for cup in cups {
      XCTAssertEqual(cup.gems.count, 1)
      XCTAssertNotEqual(cup.gems.first?.kind, .black)
    }
    XCTAssertEqual(bag.count, GameSetup.totalGemCount - cups.count)
  }
}
