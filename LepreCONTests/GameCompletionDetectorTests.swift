//
// GameCompletionDetectorTests.swift
// LepreCONTests
//
// Behavior tests for game-over vs rainbow-complete vs win.
//

import XCTest
@testable import LepreCON

final class GameCompletionDetectorTests: XCTestCase {

    private func makePlayingSession() -> GameSession {
        var session = GameSessionFactory().makeNewGame(playerNames: ["Alex"])
        session.phase = .playing
        session.unicornCupIndex = 9
        session.unicornCupID = session.cups[9].id
        for index in session.cups.indices {
            session.cups[index].gems = []
        }
        return session
    }

    private func markCompleted(
        _ session: inout GameSession,
        cupIndex: Int,
        scoredColor: GemKind = .red,
        wasMatching: Bool = false
    ) {
        session.cups[cupIndex].completion = CupCompletion(
            scoredColor: scoredColor,
            wasMatchingCupColor: wasMatching,
            goodCount: 5,
            passCount: 0,
            blemishCount: 0,
            adjustedGoodCount: 5
        )
    }

    private func markAllSixRainbowColors(_ session: inout GameSession) {
        let colors: [GemKind] = [.red, .orange, .yellow, .green, .blue, .purple]
        for (offset, color) in colors.enumerated() {
            markCompleted(&session, cupIndex: offset, scoredColor: color)
        }
    }

    private func markAllScoreableCupsCompleted(_ session: inout GameSession) {
        for index in session.cups.indices where !session.cups[index].isPotOfGold {
            markCompleted(&session, cupIndex: index, scoredColor: .red)
        }
    }

    // MARK: - Rainbow complete is not game over

    func testRainbowCompleteWithGemsStillInBagDoesNotMakeGameOver() {
        var session = makePlayingSession()
        markAllSixRainbowColors(&session)
        XCTAssertFalse(session.gemsInBag.isEmpty)

        XCTAssertTrue(GameCompletionDetector.isRainbowComplete(session: session))
        XCTAssertFalse(GameCompletionDetector.isGameOver(session: session))
        XCTAssertFalse(GameCompletionDetector.didWin(session: session))
    }

    // MARK: - Empty bag conditions

    func testEmptyBagWhileGemsStillInHandDoesNotMakeGameOver() {
        var session = makePlayingSession()
        session.gemsInBag = [Gem(kind: .red)]
        session.gemsInHand = [Gem(kind: .blue)]
        session.currentRoll = 3
        session.isTurnPlacementComplete = false

        XCTAssertFalse(GameCompletionDetector.isGameOver(session: session))
        XCTAssertTrue(GameTurnEngine.canPlaceFromHand(in: session))
    }

    func testEmptyBagWhileTurnPlacementStillInProgressDoesNotMakeGameOver() {
        var session = makePlayingSession()
        session.gemsInBag = []
        session.gemsInHand = [Gem(kind: .green)]
        session.currentRoll = 2
        session.isTurnPlacementComplete = false

        XCTAssertTrue(GameTurnEngine.isTurnInProgress(in: session))
        XCTAssertFalse(GameCompletionDetector.isGameOver(session: session))
    }

    func testEmptyBagAfterPlacementWithPendingScoreChoicesDoesNotMakeGameOver() {
        var session = makePlayingSession()
        session.gemsInBag = []
        session.gemsInHand = []
        session.currentRoll = 1
        session.isTurnPlacementComplete = true
        session.cups[2].gems = Array(repeating: Gem(kind: .red), count: 5)
        PendingScoreDetector.refreshPendingScoreChoices(in: &session)

        XCTAssertFalse(session.pendingScoreChoices.isEmpty)
        XCTAssertFalse(GameCompletionDetector.isGameOver(session: session))
    }

    func testEmptyBagAfterSkippingPendingScoringMakesGameOver() {
        var session = makePlayingSession()
        session.gemsInBag = []
        session.gemsInHand = []
        session.currentRoll = 1
        session.isTurnPlacementComplete = true
        session.cups[2].gems = Array(repeating: Gem(kind: .red), count: 5)
        PendingScoreDetector.refreshPendingScoreChoices(in: &session)

        PendingScoreDetector.clearPendingScoreChoices(in: &session)
        GameCompletionDetector.applyGameOverIfNeeded(to: &session)

        XCTAssertEqual(session.phase, .finished)
        XCTAssertTrue(GameCompletionDetector.isGameOver(session: session))
    }

    func testEmptyBagAfterConfirmingLastPendingScoreMakesGameOver() {
        var session = makePlayingSession()
        session.gemsInBag = []
        session.gemsInHand = []
        session.currentRoll = 1
        session.isTurnPlacementComplete = true
        session.cups[2].gems = Array(repeating: Gem(kind: .red), count: 5)
        PendingScoreDetector.refreshPendingScoreChoices(in: &session)

        _ = ScoreConfirmationEngine.confirmScore(session: &session, cupIndex: 2, scoringColor: .red)
        GameCompletionDetector.applyGameOverIfNeeded(to: &session)

        XCTAssertEqual(session.phase, .finished)
        XCTAssertTrue(GameCompletionDetector.isGameOver(session: session))
    }

    // MARK: - All scoreable cups completed

    func testAllNonPotCupsCompletedMakesGameOver() {
        var session = makePlayingSession()
        markAllScoreableCupsCompleted(&session)

        XCTAssertTrue(GameCompletionDetector.isGameOver(session: session))
        GameCompletionDetector.applyGameOverIfNeeded(to: &session)
        XCTAssertEqual(session.phase, .finished)
    }

    func testPotOfGoldIncompleteDoesNotPreventGameOver() {
        var session = makePlayingSession()
        markAllScoreableCupsCompleted(&session)
        let potIndex = GameSetup.potOfGoldCupIndex
        XCTAssertFalse(session.cups[potIndex].isCompleted)

        XCTAssertTrue(GameCompletionDetector.isGameOver(session: session))
    }

    func testNineScoreableCupsCompletedDoesNotMakeGameOver() {
        var session = makePlayingSession()
        for index in 0..<9 {
            markCompleted(&session, cupIndex: index)
        }

        XCTAssertFalse(GameCompletionDetector.isGameOver(session: session))
    }

    // MARK: - Win vs loss

    func testGameOverWithRainbowCompleteReportsDidWinTrue() {
        var session = makePlayingSession()
        markAllScoreableCupsCompleted(&session)
        markAllSixRainbowColors(&session)

        let status = GameCompletionDetector.status(for: session)
        XCTAssertTrue(status.isGameOver)
        XCTAssertTrue(status.isRainbowComplete)
        XCTAssertTrue(status.didWin)
    }

    func testGameOverWithIncompleteRainbowReportsDidWinFalseAndMissingColors() {
        var session = makePlayingSession()
        markAllScoreableCupsCompleted(&session)
        markCompleted(&session, cupIndex: 0, scoredColor: .red)

        let status = GameCompletionDetector.status(for: session)
        let score = FinalScoreEvaluator.evaluate(session: session)

        XCTAssertTrue(status.isGameOver)
        XCTAssertFalse(status.isRainbowComplete)
        XCTAssertFalse(status.didWin)
        XCTAssertFalse(score.missingColors.isEmpty)
    }

    // MARK: - Play blocked after game over

    func testCanRollD12IsFalseOnceGameIsOver() {
        var session = makePlayingSession()
        session.gemsInBag = []
        session.gemsInHand = []
        session.isTurnPlacementComplete = true
        GameCompletionDetector.applyGameOverIfNeeded(to: &session)
        session.phase = .finished

        XCTAssertFalse(GameTurnEngine.canRollD12(in: session))
    }

    func testCanPlaceFromHandIsFalseOnceGameIsOver() {
        var session = makePlayingSession()
        session.gemsInHand = [Gem(kind: .red)]
        session.currentRoll = 1
        session.isTurnPlacementComplete = false
        session.phase = .finished

        XCTAssertFalse(GameTurnEngine.canPlaceFromHand(in: session))
    }

    func testFinalScoreEvaluatorStillGivesGoldBonusOnlyWhenRainbowComplete() {
        var session = makePlayingSession()
        markAllScoreableCupsCompleted(&session)
        session.cups[GameSetup.potOfGoldCupIndex].gems = Array(repeating: Gem(kind: .gold), count: 3)

        let incomplete = FinalScoreEvaluator.evaluate(session: session)
        XCTAssertFalse(incomplete.isRainbowComplete)
        XCTAssertEqual(incomplete.goldPoints, 0)

        markAllSixRainbowColors(&session)
        let complete = FinalScoreEvaluator.evaluate(session: session)
        XCTAssertTrue(complete.isRainbowComplete)
        XCTAssertEqual(complete.goldPoints, 3)
    }
}
