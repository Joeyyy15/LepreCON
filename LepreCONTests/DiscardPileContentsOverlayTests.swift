//
// DiscardPileContentsOverlayTests.swift
// LepreCONTests
//
// Presentation tests for dense content-sized discard tray.
//

import XCTest
@testable import LepreCON

final class DiscardPileContentsOverlayTests: XCTestCase {

    private let tolerance: CGFloat = 0.000_1

    /// Golden 17 Pro with 4pt dock clearance: dockTop(646) − boardTop(102) − 4 = 540.
    private let goldenPlayfieldBottomLimit: CGFloat = 540

    private var metrics: BoardLayoutMetrics {
        BoardLayoutMetrics(playfieldSize: BoardDesignCanvas.referenceSize)
    }

    private var allKindCount: Int {
        GemCountDisplayBuilder.displayOrder.count
    }

    private func panelWidth(kinds: Int) -> CGFloat {
        metrics.discardTrayWidth(gemKindCount: kinds)
    }

    private func panelHeight(kinds: Int, bottomLimit: CGFloat? = nil) -> CGFloat {
        let width = panelWidth(kinds: kinds)
        return metrics.discardTrayHeight(
            gemKindCount: kinds,
            panelWidth: width,
            playfieldBottomLimit: bottomLimit ?? goldenPlayfieldBottomLimit
        )
    }

    // MARK: - Grouping

    func testGroupingProducesOneCellPerGemKindNotPerGem() {
        let gems = [
            Gem(kind: .clear), Gem(kind: .clear), Gem(kind: .clear), Gem(kind: .clear),
            Gem(kind: .gold), Gem(kind: .gold),
            Gem(kind: .red), Gem(kind: .red), Gem(kind: .red),
            Gem(kind: .black)
        ]
        let grouped = GemCountDisplayBuilder.groupedCounts(from: gems)
        XCTAssertEqual(grouped.count, 4)
        XCTAssertEqual(grouped.reduce(0) { $0 + $1.count }, gems.count)
    }

    func testEmptyDiscardGroupingIsEmpty() {
        XCTAssertTrue(GemCountDisplayBuilder.groupedCounts(from: []).isEmpty)
    }

    // MARK: - Dense cell / scale

    func testGemCellScaleIsInDenseTargetRange() {
        XCTAssertGreaterThanOrEqual(BoardLayoutMetrics.discardGemCellScale, 0.55)
        XCTAssertLessThanOrEqual(BoardLayoutMetrics.discardGemCellScale, 0.60)
        XCTAssertEqual(BoardLayoutMetrics.discardGemCellScale, 0.60, accuracy: tolerance)
    }

    func testCompactCellDimensionsAreSmallerThanHandCells() {
        let gemSize = BoardLayoutMetrics.discardContentGemSize()
        let cellHeight = BoardLayoutMetrics.discardGemCellMinHeight(gemSize: gemSize)
        let handGem = GameScreenLayout.handTrayGridGemSize
        let handCell = GameScreenLayout.handTrayGridCellMinHeight

        XCTAssertEqual(gemSize, handGem * 0.60, accuracy: tolerance)
        XCTAssertEqual(cellHeight, gemSize, accuracy: tolerance)
        XCTAssertLessThan(gemSize, handGem * 0.70)
        XCTAssertLessThan(cellHeight, handCell * 0.55)
    }

    // MARK: - Content-driven outer panel

    func testEmptyPanelIsCompactAndDoesNotFillDockSpace() {
        let maxHeight = metrics.discardTrayMaxHeight(playfieldBottomLimit: goldenPlayfieldBottomLimit)
        let height = panelHeight(kinds: 0)
        XCTAssertEqual(panelWidth(kinds: 0), BoardLayoutMetrics.discardEmptyPanelWidth, accuracy: tolerance)
        XCTAssertLessThan(height, maxHeight - 5)
    }

    func testOneGemKindProducesSmallPanel() {
        let width1 = panelWidth(kinds: 1)
        XCTAssertEqual(width1, BoardLayoutMetrics.discardPanelMinWidth, accuracy: tolerance)
        XCTAssertLessThan(width1, metrics.discardOverlayWidth * 0.55)
        XCTAssertGreaterThan(panelHeight(kinds: 1), panelHeight(kinds: 0))
    }

    func testTwoGemKindsGrowWidthAppropriately() {
        // 1–2 kinds stay at min width; growth is visible once more columns are needed.
        XCTAssertEqual(panelWidth(kinds: 1), panelWidth(kinds: 2), accuracy: tolerance)
        XCTAssertGreaterThan(panelWidth(kinds: 4), panelWidth(kinds: 2))
        XCTAssertGreaterThan(panelWidth(kinds: 6), panelWidth(kinds: 4))
    }

    func testAllSupportedKindsFitWithoutScrollingOnGoldenGeometry() {
        let kinds = allKindCount
        let width = panelWidth(kinds: kinds)
        let maxHeight = metrics.discardTrayMaxHeight(playfieldBottomLimit: goldenPlayfieldBottomLimit)
        let height = panelHeight(kinds: kinds)
        let columns = BoardLayoutMetrics.discardColumnCount(gemKindCount: kinds, panelWidth: width)
        let rows = Int(ceil(Double(kinds) / Double(columns)))
        let ideal = BoardLayoutMetrics.idealDiscardTrayHeight(
            gemKindCount: kinds,
            panelWidth: width,
            scale: 1
        )

        XCTAssertEqual(kinds, 11)
        XCTAssertEqual(columns, 6)
        XCTAssertEqual(rows, 2)
        XCTAssertLessThanOrEqual(ideal, maxHeight + 0.5)
        XCTAssertEqual(height, ideal, accuracy: 0.5)
        XCTAssertTrue(
            BoardLayoutMetrics.discardGridFitsWithoutScrolling(
                gemKindCount: kinds,
                panelWidth: width,
                maxHeight: maxHeight
            )
        )
    }

    func testAdditionalKindsWrapWithinMaxColumns() {
        let w6 = panelWidth(kinds: 6)
        let w11 = panelWidth(kinds: 11)
        XCTAssertEqual(w6, w11, accuracy: tolerance)

        let columns = BoardLayoutMetrics.discardColumnCount(gemKindCount: 11, panelWidth: w11)
        XCTAssertEqual(columns, 6)
        XCTAssertEqual(Int(ceil(Double(11) / Double(columns))), 2)
    }

    func testConstrainedGeometryFallsBackToScrolling() {
        let kinds = allKindCount
        let width = panelWidth(kinds: kinds)
        // Severely cramped vertical budget forces scroll fallback.
        let crampedMax: CGFloat = 40
        XCTAssertFalse(
            BoardLayoutMetrics.discardGridFitsWithoutScrolling(
                gemKindCount: kinds,
                panelWidth: width,
                maxHeight: crampedMax
            )
        )
        let height = BoardLayoutMetrics.discardPanelHeight(
            gemKindCount: kinds,
            panelWidth: width,
            maxHeight: crampedMax
        )
        XCTAssertEqual(height, crampedMax, accuracy: tolerance)
        let ideal = BoardLayoutMetrics.idealDiscardTrayHeight(
            gemKindCount: kinds,
            panelWidth: width,
            scale: 1
        )
        XCTAssertGreaterThan(ideal, height)
    }

    func testPanelDoesNotAutomaticallyFillAvailableDockSpace() {
        let maxHeight = metrics.discardTrayMaxHeight(playfieldBottomLimit: goldenPlayfieldBottomLimit)
        XCTAssertNotEqual(panelHeight(kinds: 0), maxHeight, accuracy: tolerance)
        XCTAssertNotEqual(panelHeight(kinds: 1), maxHeight, accuracy: tolerance)
    }

    func testTrayTopStaysAnchoredBelowDiscardControl() {
        let h1 = panelHeight(kinds: 1)
        let hAll = panelHeight(kinds: allKindCount)
        let top1 = metrics.canvasHeight - metrics.discardTrayBottomPadding(forHeight: h1) - h1
        let topAll = metrics.canvasHeight - metrics.discardTrayBottomPadding(forHeight: hAll) - hAll
        XCTAssertEqual(top1, topAll, accuracy: tolerance)
        XCTAssertEqual(
            top1,
            metrics.discardControlBottomInCanvas + BoardLayoutMetrics.discardTrayGapBelowControl,
            accuracy: tolerance
        )
    }

    // MARK: - Required discard

    func testRequiredDiscardAutoOpenAndCloseSurfaceUnchanged() async {
        await MainActor.run {
            var session = GameSessionFactory().makeNewGame(playerNames: ["Player 1"])
            session.phase = .playing
            for index in session.cups.indices {
                session.cups[index].gems = []
            }
            let discardGem = Gem(kind: .pink)
            session.gemsInHand = [discardGem, Gem(kind: .blue)]
            session.currentRoll = 2
            session.nextPlacementCupIndex = 0
            session.placementsCompletedInCurrentRotation = session.cups.count
            session.isTurnPlacementComplete = false
            session.unicornCupIndex = 9
            session.unicornCupID = session.cups[9].id

            let viewModel = GameViewModel(session: session)
            XCTAssertTrue(viewModel.shouldPresentDiscardContents)
            _ = viewModel.placeHandGem(kind: .pink)
            XCTAssertFalse(viewModel.shouldPresentDiscardContents)
            XCTAssertEqual(viewModel.discardGemCounts.count, 1)
        }
    }
}
