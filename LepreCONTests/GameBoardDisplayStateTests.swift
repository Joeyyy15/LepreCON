//
// GameBoardDisplayStateTests.swift
// LepreCONTests
//

import XCTest
@testable import LepreCON

final class GameBoardDisplayStateTests: XCTestCase {

    private func gems(_ kinds: [GemKind]) -> [Gem] {
        kinds.map { Gem(kind: $0) }
    }

    private func sessionWithPendingScore(cupIndex: Int, gemKinds: [GemKind]) -> GameSession {
        var session = GameSessionFactory().makeNewGame(playerNames: ["Alex"])
        session.phase = .playing
        for index in session.cups.indices {
            session.cups[index].gems = []
        }
        session.cups[cupIndex].gems = gems(gemKinds)
        session.isTurnPlacementComplete = true
        PendingScoreDetector.refreshPendingScoreChoices(in: &session)
        return session
    }

    func testDisplayStateIncludesPendingScoreChoicesForScoreableCup() {
        let session = sessionWithPendingScore(cupIndex: 2, gemKinds: Array(repeating: .blue, count: 5))
        let display = GameBoardDisplayState.from(session: session)

        XCTAssertEqual(display.pendingScoringCups.count, 1)
        XCTAssertEqual(display.pendingScoringCups.first?.cupIndex, 2)
        XCTAssertEqual(display.pendingScoringCups.first?.pendingOptions.first?.scoringColor, .blue)

        let lane = display.rainbowLanes.first { $0.cupIndex == 2 }
        XCTAssertTrue(lane?.scoring.hasPendingOptions == true)
        XCTAssertEqual(lane?.scoring.pendingOptions.first?.scoringColor, .blue)
    }

    func testDisplayStateMarksCompletedCupWithScoredColor() {
        var session = sessionWithPendingScore(cupIndex: 2, gemKinds: Array(repeating: .red, count: 5))
        _ = ScoreConfirmationEngine.confirmScore(session: &session, cupIndex: 2, scoringColor: .red)

        let display = GameBoardDisplayState.from(session: session)
        let lane = display.rainbowLanes.first { $0.cupIndex == 2 }

        XCTAssertTrue(lane?.scoring.isCompleted == true)
        XCTAssertEqual(lane?.scoring.completedCaption, "Scored Red")
        XCTAssertTrue(display.pendingScoringCups.isEmpty)
    }

    func testMultipleScoringCandidatesAppearInPendingOptions() {
        var session = sessionWithPendingScore(cupIndex: 2, gemKinds: Array(repeating: .clear, count: 5))
        let display = GameBoardDisplayState.from(session: session)

        let options = display.rainbowLanes.first { $0.cupIndex == 2 }?.scoring.pendingOptions ?? []
        XCTAssertGreaterThan(options.count, 1)
    }

    func testDisplayStateMarksExactlyOneCupWithUnicorn() {
        let session = GameSessionFactory().makeNewGame(playerNames: ["Alex"])
        let display = GameBoardDisplayState.from(session: session)

        let unicornCupCount =
            display.rainbowLanes.filter(\.hasUnicorn).count
            + display.bottomRow.filter { $0.cupSlot.hasUnicorn }.count

        XCTAssertEqual(unicornCupCount, 1)
        guard let unicornCupIndex = session.unicornCupIndex else {
            XCTFail("Expected unicornCupIndex on new game")
            return
        }

        let laneMatch = display.rainbowLanes.first { $0.cupIndex == unicornCupIndex }?.hasUnicorn == true
        let bottomMatch = display.bottomRow.first { $0.cupSlot.cupIndex == unicornCupIndex }?.cupSlot.hasUnicorn == true
        XCTAssertTrue(laneMatch || bottomMatch)
    }

    func testDisplayedUnicornCupMatchesSessionIndex() {
        var session = GameSessionFactory().makeNewGame(playerNames: ["Alex"])
        session.unicornCupIndex = 6
        session.unicornCupID = session.cups[6].id

        let display = GameBoardDisplayState.from(session: session)
        let blueLane = display.rainbowLanes.first { $0.cupIndex == 6 }

        XCTAssertEqual(blueLane?.hasUnicorn, true)
        XCTAssertEqual(display.rainbowLanes.filter(\.hasUnicorn).count, 1)
    }

    // MARK: - Grouped gem counts

    func testCupWithMultipleSameKindGemsProducesOneGroupedCount() {
        var session = GameSessionFactory().makeNewGame(playerNames: ["Alex"])
        session.phase = .playing
        for index in session.cups.indices {
            session.cups[index].gems = []
        }
        session.cups[2].gems = gems(Array(repeating: .red, count: 3))

        let display = GameBoardDisplayState.from(session: session)
        let lane = display.rainbowLanes.first { $0.cupIndex == 2 }

        XCTAssertEqual(lane?.gemCounts.count, 1)
        XCTAssertEqual(lane?.gemCounts.first?.kind, .red)
        XCTAssertEqual(lane?.gemCounts.first?.count, 3)
    }

    func testGroupingIsByGemKindNotImageName() {
        var session = GameSessionFactory().makeNewGame(playerNames: ["Alex"])
        session.phase = .playing
        for index in session.cups.indices {
            session.cups[index].gems = []
        }
        session.cups[4].gems = [
            Gem(kind: .yellow),
            Gem(kind: .yellow),
            Gem(kind: .gold),
            Gem(kind: .gold)
        ]

        let display = GameBoardDisplayState.from(session: session)
        let lane = display.rainbowLanes.first { $0.cupIndex == 4 }
        let kinds = lane?.gemCounts.map(\.kind) ?? []

        XCTAssertEqual(lane?.gemCounts.count, 2)
        XCTAssertEqual(Set(kinds), Set([.yellow, .gold]))
        XCTAssertEqual(lane?.gemCounts.first { $0.kind == .yellow }?.imageName, "gem_yellow")
        XCTAssertEqual(lane?.gemCounts.first { $0.kind == .gold }?.imageName, "gem_yellow")
    }

    func testClearAndWhiteAreSeparateGroupsDespiteSharedAsset() {
        var session = GameSessionFactory().makeNewGame(playerNames: ["Alex"])
        session.phase = .playing
        for index in session.cups.indices {
            session.cups[index].gems = []
        }
        session.cups[0].gems = [Gem(kind: .white), Gem(kind: .clear)]

        let display = GameBoardDisplayState.from(session: session)
        let cloud = display.bottomRow.first { $0.cupSlot.cupIndex == 0 }

        XCTAssertEqual(cloud?.cupSlot.gemCounts.count, 2)
        XCTAssertEqual(cloud?.cupSlot.gemCounts.map(\.kind), [.white, .clear])
        XCTAssertEqual(cloud?.cupSlot.gemCounts.first { $0.kind == .white }?.shortLabel, "W")
        XCTAssertEqual(cloud?.cupSlot.gemCounts.first { $0.kind == .clear }?.shortLabel, "C")
    }

    func testPinkAndPurpleAreSeparateGroupsDespiteSharedAsset() {
        var session = GameSessionFactory().makeNewGame(playerNames: ["Alex"])
        session.phase = .playing
        for index in session.cups.indices {
            session.cups[index].gems = []
        }
        session.cups[7].gems = [Gem(kind: .purple), Gem(kind: .pink)]

        let display = GameBoardDisplayState.from(session: session)
        let lane = display.rainbowLanes.first { $0.cupIndex == 7 }

        XCTAssertEqual(lane?.gemCounts.count, 2)
        XCTAssertEqual(Set(lane?.gemCounts.map(\.kind) ?? []), Set([.purple, .pink]))
    }

    func testAllGemKindsHaveNonEmptyDisplayMetadata() {
        for kind in GemKind.allCases {
            let item = GemCountDisplayItem(kind: kind, count: 1)
            XCTAssertFalse(item.imageName.isEmpty, "\(kind)")
            XCTAssertFalse(item.displayName.isEmpty, "\(kind)")
            XCTAssertEqual(item.imageName, kind.imageAssetName)
        }
    }

    // MARK: - Playability UI display

    func testHandGemOverlayLabelsAreNonEmptyForAmbiguousKinds() {
        let specialKinds: [GemKind] = [.gold, .clear, .white, .pink, .black]
        for kind in specialKinds {
            XCTAssertNotNil(kind.handGemOverlayLabel, "\(kind)")
            XCTAssertFalse(kind.handGemOverlayLabel?.isEmpty ?? true, "\(kind)")
        }
        XCTAssertNil(GemKind.red.handGemOverlayLabel)
    }

    func testUnicornStatusShowsNotCapturedByDefault() {
        let session = GameSessionFactory().makeNewGame(playerNames: ["Alex"])
        let display = GameBoardDisplayState.from(session: session)

        XCTAssertFalse(display.unicornStatus.isCaptured)
        XCTAssertEqual(display.unicornStatus.statusLine, "Unicorn: Not captured")
    }

    func testUnicornStatusShowsCapturedAfterCapture() {
        var session = GameSessionFactory().makeNewGame(playerNames: ["Alex"])
        session.phase = .playing
        for index in session.cups.indices {
            session.cups[index].gems = []
        }
        session.cups[2].gems = Array(repeating: Gem(kind: .red), count: 5)
        session.unicornCupIndex = 2
        session.unicornCupID = session.cups[2].id
        session.isTurnPlacementComplete = true
        PendingScoreDetector.refreshPendingScoreChoices(in: &session)
        _ = ScoreConfirmationEngine.confirmScore(session: &session, cupIndex: 2, scoringColor: .red)

        let display = GameBoardDisplayState.from(session: session)
        XCTAssertTrue(display.unicornStatus.isCaptured)
        XCTAssertEqual(display.unicornStatus.statusLine, "Unicorn: Captured")
    }

    func testGameOverDisplayIncludesUnicornCaptureDetailWhenRainbowComplete() {
        var session = GameSessionFactory().makeNewGame(playerNames: ["Alex"])
        session.phase = .playing
        for index in session.cups.indices {
            session.cups[index].gems = []
        }
        session.unicornCaptured = true
        markAllScoreableCupsWithSixRainbowColors(&session)

        let display = GameBoardDisplayState.from(session: session)

        XCTAssertNotNil(display.gameOver)
        XCTAssertTrue(display.gameOver?.unicornStatus.isCaptured ?? false)
        XCTAssertTrue(
            display.gameOver?.unicornStatus.gameOverDetailLine.contains("+3") ?? false
        )
    }

    func testGameOverDisplayShowsCapturedWithoutBonusWhenRainbowIncomplete() {
        var session = GameSessionFactory().makeNewGame(playerNames: ["Alex"])
        session.phase = .finished
        session.unicornCaptured = true
        markAllScoreableCupsRedOnly(&session)

        let score = FinalScoreEvaluator.evaluate(session: session)
        let status = GameBoardDisplayState.unicornStatusDisplay(session: session, finalScore: score)

        XCTAssertFalse(score.isRainbowComplete)
        XCTAssertTrue(status.gameOverDetailLine.contains("no bonus"))
    }

    private func markAllScoreableCupsRedOnly(_ session: inout GameSession) {
        for index in session.cups.indices where !session.cups[index].isPotOfGold {
            session.cups[index].completion = CupCompletion(
                scoredColor: .red,
                wasMatchingCupColor: false,
                goodCount: 5,
                passCount: 0,
                blemishCount: 0,
                adjustedGoodCount: 5
            )
        }
    }

    private func markAllScoreableCupsWithSixRainbowColors(_ session: inout GameSession) {
        let colors: [GemKind] = [.red, .orange, .yellow, .green, .blue, .purple]
        var colorIndex = 0
        for index in session.cups.indices where !session.cups[index].isPotOfGold {
            let color = colors[colorIndex % colors.count]
            session.cups[index].completion = CupCompletion(
                scoredColor: color,
                wasMatchingCupColor: false,
                goodCount: 5,
                passCount: 0,
                blemishCount: 0,
                adjustedGoodCount: 5
            )
            colorIndex += 1
        }
    }
}
