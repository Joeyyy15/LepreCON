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
}
