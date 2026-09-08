//
// DiscardPileContentsOverlayTests.swift
// LepreCONTests
//
// Presentation tests for the downward discard tray (fixed top, extending bottom).
//

import XCTest
@testable import LepreCON

final class DiscardPileContentsOverlayTests: XCTestCase {

    private let tolerance: CGFloat = 0.000_1

    /// Golden 17 Pro with 4pt dock clearance: dockTop(646) − boardTop(102) − 4 = 540.
    private let goldenPlayfieldBottomLimit: CGFloat = 540

    func testTrayTopStaysFixedWhenBottomExtends() {
        let metrics = BoardLayoutMetrics(playfieldSize: BoardDesignCanvas.referenceSize)
        let fixedTop = metrics.discardTrayFixedTopInPlayfield

        let shortLimit = fixedTop + 50
        let tallLimit = fixedTop + 120
        let shortHeight = metrics.discardTrayHeight(gemKindCount: 4, playfieldBottomLimit: shortLimit)
        let tallHeight = metrics.discardTrayHeight(gemKindCount: 4, playfieldBottomLimit: tallLimit)

        XCTAssertEqual(shortHeight, 50, accuracy: tolerance)
        XCTAssertEqual(tallHeight, 120, accuracy: tolerance)

        // Top derived from padding formula stays identical.
        let shortPad = metrics.discardTrayBottomPadding(forHeight: shortHeight)
        let tallPad = metrics.discardTrayBottomPadding(forHeight: tallHeight)
        let shortTopCanvas = metrics.canvasHeight - shortPad - shortHeight
        let tallTopCanvas = metrics.canvasHeight - tallPad - tallHeight
        XCTAssertEqual(shortTopCanvas, tallTopCanvas, accuracy: tolerance)
        XCTAssertEqual(
            shortTopCanvas,
            metrics.discardControlBottomInCanvas + BoardLayoutMetrics.discardTrayGapBelowControl,
            accuracy: tolerance
        )
    }

    func testTrayBottomExtendsToDockLimitWithSafeClearance() {
        let metrics = BoardLayoutMetrics(playfieldSize: BoardDesignCanvas.referenceSize)
        let height = metrics.discardTrayHeight(
            gemKindCount: 3,
            playfieldBottomLimit: goldenPlayfieldBottomLimit
        )
        let top = metrics.discardTrayFixedTopInPlayfield
        let bottom = top + height

        XCTAssertEqual(bottom, goldenPlayfieldBottomLimit, accuracy: tolerance)
        XCTAssertGreaterThan(height, 0)
        // Height increased vs old content-capped ~77 with 8pt clearance (~77).
        XCTAssertGreaterThan(height, 70)
    }

    func testAvailableHeightNeverNegativeEvenWhenCramped() {
        let metrics = BoardLayoutMetrics(playfieldSize: BoardDesignCanvas.referenceSize)
        let height = metrics.discardTrayHeight(
            gemKindCount: 4,
            playfieldBottomLimit: 0
        )
        XCTAssertEqual(height, 0, accuracy: tolerance)
    }

    func testHeightGrowsOnlyByMovingBottomEdge() {
        let metrics = BoardLayoutMetrics(playfieldSize: BoardDesignCanvas.referenceSize)
        let top = metrics.discardTrayFixedTopInPlayfield
        let h1 = metrics.discardTrayHeight(gemKindCount: 2, playfieldBottomLimit: top + 40)
        let h2 = metrics.discardTrayHeight(gemKindCount: 2, playfieldBottomLimit: top + 90)
        XCTAssertEqual(h2 - h1, 50, accuracy: tolerance)
        XCTAssertEqual(metrics.discardTrayFixedTopInPlayfield, top, accuracy: tolerance)
    }

    func testGemCellScaleIsModestRelativeToHand() {
        XCTAssertGreaterThanOrEqual(BoardLayoutMetrics.discardGemCellScale, 0.85)
        XCTAssertLessThanOrEqual(BoardLayoutMetrics.discardGemCellScale, 0.95)
    }

    func testIdealContentMayExceedTrayHeightSoOverflowScrolls() {
        let metrics = BoardLayoutMetrics(playfieldSize: BoardDesignCanvas.referenceSize)
        let trayHeight = metrics.discardTrayHeight(
            gemKindCount: 12,
            playfieldBottomLimit: goldenPlayfieldBottomLimit
        )
        let ideal = BoardLayoutMetrics.idealDiscardTrayHeight(
            gemKindCount: 12,
            panelWidth: metrics.discardOverlayWidth,
            scale: 1
        )
        // Two-row ideal is taller than dock-capped tray → contents scroll inside.
        XCTAssertGreaterThan(ideal, trayHeight)
    }

    func testRequiredDiscardAutoOpenAndCloseSurfaceUnchanged() async {
        await MainActor.run {
            var session = GameSessionFactory().makeNewGame(playerNames: ["Player 1"])
            session.phase = .playing
            for index in session.cups.indices {
                session.cups[index].gems = []
            }
            let discardGem = Gem(kind: .pink)
            let remaining = Gem(kind: .blue)
            session.gemsInHand = [discardGem, remaining]
            session.currentRoll = 2
            session.nextPlacementCupIndex = 0
            session.placementsCompletedInCurrentRotation = session.cups.count
            session.isTurnPlacementComplete = false
            session.unicornCupIndex = 9
            session.unicornCupID = session.cups[9].id

            let viewModel = GameViewModel(session: session)
            XCTAssertTrue(viewModel.isDiscardRequired)
            XCTAssertTrue(viewModel.shouldPresentDiscardContents)

            _ = viewModel.placeHandGem(kind: .pink)
            XCTAssertFalse(viewModel.isDiscardRequired)
            XCTAssertFalse(viewModel.shouldPresentDiscardContents)
        }
    }
}
