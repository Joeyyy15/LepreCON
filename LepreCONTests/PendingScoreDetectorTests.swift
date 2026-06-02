//
// PendingScoreDetectorTests.swift
// LepreCONTests
//
// Tests for pending score detection after placement (no auto-completion).
//

import XCTest
@testable import LepreCON

final class PendingScoreDetectorTests: XCTestCase {

    private func makeBoardCups() -> [Cup] {
        GameSetup.makePhysicalCups()
    }

    private func gems(_ kinds: [GemKind]) -> [Gem] {
        kinds.map { Gem(kind: $0) }
    }

    private func playingSession(cups: [Cup]) -> GameSession {
        GameSession(phase: .playing, cups: cups)
    }

    private func pendingChoice(
        in session: GameSession,
        cupIndex: Int
    ) -> PendingScoreChoice? {
        session.pendingScoreChoices.first { $0.cupIndex == cupIndex }
    }

    // MARK: - Detection

    func testScoreableCupCreatesPendingScoreChoice() {
        var cups = makeBoardCups()
        cups[2].gems = gems(Array(repeating: .red, count: 5))

        let choices = PendingScoreDetector.detectPendingChoices(in: playingSession(cups: cups))

        XCTAssertEqual(choices.count, 1)
        XCTAssertEqual(choices.first?.cupIndex, 2)
        XCTAssertNotNil(choices.first?.candidates.first { $0.scoringColor == .red })
    }

    func testNonScoreableCupDoesNotCreatePendingScoreChoice() {
        var cups = makeBoardCups()
        cups[2].gems = gems([.red, .red, .green])

        let choices = PendingScoreDetector.detectPendingChoices(in: playingSession(cups: cups))

        XCTAssertTrue(choices.isEmpty)
    }

    func testPotOfGoldDoesNotCreatePendingScoreChoice() {
        var cups = makeBoardCups()
        cups[GameSetup.potOfGoldCupIndex].gems = gems(Array(repeating: .red, count: 5))

        let choices = PendingScoreDetector.detectPendingChoices(in: playingSession(cups: cups))

        XCTAssertNil(pendingChoice(in: GameSession(cups: cups, pendingScoreChoices: choices), cupIndex: GameSetup.potOfGoldCupIndex))
        XCTAssertTrue(choices.allSatisfy { $0.cupIndex != GameSetup.potOfGoldCupIndex })
    }

    func testCompletedCupDoesNotCreatePendingScoreChoice() {
        var cups = makeBoardCups()
        cups[2].gems = gems(Array(repeating: .red, count: 5))
        cups[2].completion = CupCompletion(
            scoredColor: .red,
            wasMatchingCupColor: true,
            goodCount: 5,
            passCount: 0,
            blemishCount: 0,
            adjustedGoodCount: 5
        )

        let choices = PendingScoreDetector.detectPendingChoices(in: playingSession(cups: cups))

        XCTAssertTrue(choices.isEmpty)
    }

    func testCupWithMultipleValidCandidatesStoresAllCandidates() {
        var cups = makeBoardCups()
        cups[2].gems = gems(Array(repeating: .clear, count: 5))

        guard let choice = PendingScoreDetector.detectPendingChoices(in: playingSession(cups: cups)).first else {
            XCTFail("Expected a pending choice")
            return
        }

        XCTAssertEqual(choice.candidates.count, 6)
        XCTAssertEqual(Set(choice.candidates.map(\.scoringColor)), Set(ScoreEvaluator.rainbowScoringColors))
    }

    // MARK: - Matching cup color examples (no completion)

    func testRedCupWithFiveBlueGemsCreatesPendingBlueOptionWithoutCompletingCup() {
        var cups = makeBoardCups()
        cups[2].gems = gems(Array(repeating: .blue, count: 5))

        let choices = PendingScoreDetector.detectPendingChoices(in: playingSession(cups: cups))
        let blue = choices.first?.candidates.first { $0.scoringColor == .blue }

        XCTAssertNil(cups[2].completion)
        XCTAssertFalse(cups[2].isCompleted)
        XCTAssertEqual(blue?.isMatchingCupColor, false)
    }

    func testBlueCupWithFiveBlueGemsCreatesPendingBlueOptionWithMatchingCupColor() {
        var cups = makeBoardCups()
        cups[6].gems = gems(Array(repeating: .blue, count: 5))

        let choices = PendingScoreDetector.detectPendingChoices(in: playingSession(cups: cups))
        let blue = choices.first { $0.cupIndex == 6 }?.candidates.first { $0.scoringColor == .blue }

        XCTAssertNil(cups[6].completion)
        XCTAssertEqual(blue?.isMatchingCupColor, true)
    }

    func testWhiteCloudCupWithFiveBlueGemsCreatesPendingBlueOptionWithNonMatchingCupColor() {
        var cups = makeBoardCups()
        cups[0].gems = gems(Array(repeating: .blue, count: 5))

        let choices = PendingScoreDetector.detectPendingChoices(in: playingSession(cups: cups))
        let blue = choices.first { $0.cupIndex == 0 }?.candidates.first { $0.scoringColor == .blue }

        XCTAssertEqual(cups[0].color, .white)
        XCTAssertNil(cups[0].completion)
        XCTAssertEqual(blue?.isMatchingCupColor, false)
    }

    // MARK: - Turn integration via GameTurnEngine

    private func makePlayingSession(cupsEmpty: Bool = true) -> GameSession {
        var session = GameSessionFactory().makeNewGame(playerNames: ["Alex"])
        session.phase = .playing
        session.gemsInBag = []
        session.gemsInHand = []
        session.discardPile = []
        session.currentRoll = nil
        session.pendingScoreChoices = []
        if cupsEmpty {
            for index in session.cups.indices {
                session.cups[index].gems = []
            }
        }
        session.unicornCupIndex = 9
        session.unicornCupID = session.cups[9].id
        return session
    }

    func testPendingScoreChoicesRefreshAfterPlacementEnds() {
        var session = makePlayingSession()
        session.cups[2].gems = gems(Array(repeating: .red, count: 5))
        session.cups[0].gems = []
        session.gemsInHand = [Gem(kind: .green)]
        session.currentRoll = 1
        session.nextPlacementCupIndex = 0

        _ = GameTurnEngine.placeGemInCurrentCup(session: &session, gemID: session.gemsInHand[0].id)

        XCTAssertTrue(session.isTurnPlacementComplete)
        XCTAssertEqual(session.pendingScoreChoices.count, 1)
        XCTAssertEqual(session.pendingScoreChoices.first?.cupIndex, 2)
        XCTAssertNil(session.cups[2].completion)
    }

    func testPlacementEndRefreshesPendingScoreChoicesFromBoardState() {
        var session = makePlayingSession()
        session.cups[6].gems = gems(Array(repeating: .blue, count: 5))
        session.cups[1].gems = []
        session.gemsInHand = [Gem(kind: .yellow)]
        session.currentRoll = 1
        session.nextPlacementCupIndex = 1

        _ = GameTurnEngine.placeGemInCurrentCup(session: &session, gemID: session.gemsInHand[0].id)

        XCTAssertTrue(session.isTurnPlacementComplete)
        XCTAssertEqual(session.pendingScoreChoices.count, 1)
        XCTAssertEqual(session.pendingScoreChoices.first?.cupIndex, 6)
        XCTAssertNil(session.cups[6].completion)
    }

    func testStartingNewTurnRequiresSkippingOrConfirmingPendingScoresFirst() {
        var session = makePlayingSession()
        session.pendingScoreChoices = [
            PendingScoreChoice(
                cupIndex: 2,
                candidates: [
                    CupScoreCandidate(
                        scoringColor: .red,
                        goodCount: 5,
                        passCount: 0,
                        blemishCount: 0,
                        adjustedGoodCount: 5,
                        isMatchingCupColor: true
                    )
                ]
            )
        ]
        session.isTurnPlacementComplete = true
        session.currentRoll = 1
        session.gemsInBag = [Gem(kind: .green)]

        let blockedResult = GameTurnEngine.beginTurn(session: &session, roll: 1)
        if case .failure(let error) = blockedResult {
            XCTAssertEqual(error, .pendingScoreChoicesUnresolved)
        } else {
            XCTFail("Expected beginTurn to fail while pending score choices exist")
        }
        XCTAssertFalse(session.pendingScoreChoices.isEmpty)

        PendingScoreDetector.clearPendingScoreChoices(in: &session)
        assertSuccess(GameTurnEngine.beginTurn(session: &session, roll: 1))
        XCTAssertTrue(session.pendingScoreChoices.isEmpty)
    }

    private func assertSuccess(
        _ result: Result<Void, GameTurnError>,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        if case .failure(let error) = result {
            XCTFail("Expected success, got \(error)", file: file, line: line)
        }
    }
}
