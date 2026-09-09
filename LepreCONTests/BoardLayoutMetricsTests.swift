//
// BoardLayoutMetricsTests.swift
// LepreCONTests
//
// Stage 2: golden canvas scaling invariants for board geometry.
//

import XCTest
@testable import LepreCON

final class BoardLayoutMetricsTests: XCTestCase {

    private let tolerance: CGFloat = 0.000_1

    func testGoldenPlayfieldMatchesReferenceMetricsAtScaleOne() {
        let metrics = BoardLayoutMetrics(playfieldSize: BoardDesignCanvas.referenceSize)
        let reference = BoardReferenceMetrics.golden

        XCTAssertEqual(metrics.canvasFit.scale, 1, accuracy: tolerance)
        XCTAssertEqual(metrics.canvasFit.origin.x, 0, accuracy: tolerance)
        XCTAssertEqual(metrics.canvasFit.origin.y, 0, accuracy: tolerance)
        XCTAssertEqual(metrics.canvasWidth, 390, accuracy: tolerance)
        XCTAssertEqual(metrics.canvasHeight, 540, accuracy: tolerance)

        XCTAssertEqual(metrics.laneWidth, reference.laneWidth, accuracy: tolerance)
        XCTAssertEqual(metrics.laneHeight, reference.laneHeight, accuracy: tolerance)
        XCTAssertEqual(metrics.cloudWidth, reference.cloudWidth, accuracy: tolerance)
        XCTAssertEqual(metrics.cloudHeight, reference.cloudHeight, accuracy: tolerance)
        XCTAssertEqual(metrics.potWidth, reference.potWidth, accuracy: tolerance)
        XCTAssertEqual(metrics.potHeight, reference.potHeight, accuracy: tolerance)
        XCTAssertEqual(metrics.discardPileWidth, reference.discardPileWidth, accuracy: tolerance)
        XCTAssertEqual(metrics.discardPileCompactHeight, reference.discardPileCompactHeight, accuracy: tolerance)
        XCTAssertEqual(metrics.bottomRowBottomInset, reference.bottomRowBottomInset, accuracy: tolerance)
        XCTAssertEqual(metrics.discardOverlayWidth, reference.discardOverlayWidth, accuracy: tolerance)
        XCTAssertEqual(metrics.discardOverlayHeight, reference.discardOverlayHeight, accuracy: tolerance)
        XCTAssertEqual(
            metrics.contentVerticalOffset,
            BoardReferenceMetrics.contentVerticalOffset,
            accuracy: tolerance
        )
    }

    func testContentVerticalOffsetIsCentralizedAndScalesWithCanvasFit() {
        XCTAssertEqual(BoardReferenceMetrics.contentVerticalOffset, 93, accuracy: tolerance)

        let identity = BoardLayoutMetrics(playfieldSize: BoardDesignCanvas.referenceSize)
        XCTAssertEqual(identity.canvasFit.scale, 1, accuracy: tolerance)
        XCTAssertEqual(identity.contentVerticalOffset, 93, accuracy: tolerance)

        let half = BoardLayoutMetrics(playfieldSize: CGSize(width: 195, height: 270))
        XCTAssertEqual(half.canvasFit.scale, 0.5, accuracy: tolerance)
        XCTAssertEqual(half.contentVerticalOffset, 46.5, accuracy: tolerance)

        let taller = BoardLayoutMetrics(playfieldSize: CGSize(width: 390, height: 800))
        XCTAssertEqual(taller.canvasFit.scale, 1, accuracy: tolerance)
        XCTAssertEqual(taller.contentVerticalOffset, 93, accuracy: tolerance)
    }

    func testDiscardTrayAnchorsBelowControlWithContentSizedHeight() {
        let metrics = BoardLayoutMetrics(playfieldSize: BoardDesignCanvas.referenceSize)
        let playfieldBottomLimit: CGFloat = 540
        let maxHeight = metrics.discardTrayMaxHeight(playfieldBottomLimit: playfieldBottomLimit)

        let emptyWidth = metrics.discardTrayWidth(gemKindCount: 0)
        let fewWidth = metrics.discardTrayWidth(gemKindCount: 2)
        let manyWidth = metrics.discardTrayWidth(gemKindCount: 12)

        let empty = metrics.discardTrayHeight(
            gemKindCount: 0,
            panelWidth: emptyWidth,
            playfieldBottomLimit: playfieldBottomLimit
        )
        let few = metrics.discardTrayHeight(
            gemKindCount: 2,
            panelWidth: fewWidth,
            playfieldBottomLimit: playfieldBottomLimit
        )
        let many = metrics.discardTrayHeight(
            gemKindCount: 12,
            panelWidth: manyWidth,
            playfieldBottomLimit: playfieldBottomLimit
        )

        // Content-sized: empty is compact; many is taller but still ≤ dock max.
        XCTAssertLessThan(empty, few)
        XCTAssertLessThanOrEqual(few, many + 0.000_1)
        XCTAssertLessThanOrEqual(many, maxHeight + 0.000_1)
        XCTAssertLessThan(empty, maxHeight - 5)

        let cramped = metrics.discardTrayHeight(
            gemKindCount: 3,
            panelWidth: fewWidth,
            playfieldBottomLimit: 0
        )
        XCTAssertEqual(cramped, 0, accuracy: 0.000_1)
    }

    func testGoldenArtMetricsRemainFrozenFromArtCanvasNotFitBox() {
        let fromArt = BoardReferenceMetrics.derived(from: BoardReferenceMetrics.artCanvasSize)
        let fromFitBox = BoardReferenceMetrics.derived(from: BoardDesignCanvas.referenceSize)

        XCTAssertEqual(BoardReferenceMetrics.artCanvasSize.width, 390)
        XCTAssertEqual(BoardReferenceMetrics.artCanvasSize.height, 636)
        XCTAssertEqual(BoardReferenceMetrics.golden, fromArt)
        XCTAssertNotEqual(BoardReferenceMetrics.golden.laneHeight, fromFitBox.laneHeight)
        XCTAssertEqual(BoardReferenceMetrics.golden.laneWidth, fromArt.laneWidth, accuracy: tolerance)
        XCTAssertEqual(BoardReferenceMetrics.golden.cloudWidth, fromArt.cloudWidth, accuracy: tolerance)
        XCTAssertEqual(BoardReferenceMetrics.golden.potHeight, fromArt.potHeight, accuracy: tolerance)
        XCTAssertEqual(BoardReferenceMetrics.golden.bottomRowBottomInset, fromArt.bottomRowBottomInset, accuracy: tolerance)
    }

    func testTallerPlayfieldScalesUniformlyAndLetterboxes() {
        let available = CGSize(width: 390, height: 800)
        let metrics = BoardLayoutMetrics(playfieldSize: available)
        let reference = BoardReferenceMetrics.golden

        XCTAssertEqual(metrics.canvasFit.scale, 1, accuracy: tolerance)
        XCTAssertEqual(metrics.canvasFit.origin.x, 0, accuracy: tolerance)
        XCTAssertEqual(metrics.canvasFit.origin.y, (800 - 540) / 2, accuracy: tolerance)
        XCTAssertEqual(metrics.laneWidth, reference.laneWidth, accuracy: tolerance)
        XCTAssertEqual(metrics.cloudHeight, reference.cloudHeight, accuracy: tolerance)
        XCTAssertEqual(metrics.laneHeight / metrics.cloudHeight, reference.laneHeight / reference.cloudHeight, accuracy: tolerance)
    }

    func testWiderPlayfieldScalesUniformlyAndPillarboxes() {
        let available = CGSize(width: 500, height: 540)
        let metrics = BoardLayoutMetrics(playfieldSize: available)
        let reference = BoardReferenceMetrics.golden

        XCTAssertEqual(metrics.canvasFit.scale, 1, accuracy: tolerance)
        XCTAssertEqual(metrics.canvasFit.origin.x, (500 - 390) / 2, accuracy: tolerance)
        XCTAssertEqual(metrics.canvasFit.origin.y, 0, accuracy: tolerance)
        XCTAssertEqual(metrics.potWidth, reference.potWidth, accuracy: tolerance)
        XCTAssertEqual(metrics.lanesRowWidth, 6 * reference.laneWidth + 5 * reference.laneSpacing, accuracy: tolerance)
    }

    func testSmallerPlayfieldDownscalesAllBoardGeometryBySameFactor() {
        let scale: CGFloat = 0.5
        let available = CGSize(width: 390 * scale, height: 540 * scale)
        let metrics = BoardLayoutMetrics(playfieldSize: available)
        let reference = BoardReferenceMetrics.golden

        XCTAssertEqual(metrics.canvasFit.scale, scale, accuracy: tolerance)
        XCTAssertEqual(metrics.laneWidth, reference.laneWidth * scale, accuracy: tolerance)
        XCTAssertEqual(metrics.laneHeight, reference.laneHeight * scale, accuracy: tolerance)
        XCTAssertEqual(metrics.cloudWidth, reference.cloudWidth * scale, accuracy: tolerance)
        XCTAssertEqual(metrics.cloudHeight, reference.cloudHeight * scale, accuracy: tolerance)
        XCTAssertEqual(metrics.potWidth, reference.potWidth * scale, accuracy: tolerance)
        XCTAssertEqual(metrics.potHeight, reference.potHeight * scale, accuracy: tolerance)
        XCTAssertEqual(metrics.discardPileWidth, reference.discardPileWidth * scale, accuracy: tolerance)
        XCTAssertEqual(metrics.discardOverlayHeight, reference.discardOverlayHeight * scale, accuracy: tolerance)
        XCTAssertGreaterThanOrEqual(metrics.laneWidth, 0)
        XCTAssertGreaterThanOrEqual(metrics.laneHeight, 0)
    }

    func testRatioInvariantsAcrossRepresentativePlayfields() {
        let reference = BoardReferenceMetrics.golden
        let expectedCloudOverLane = reference.cloudWidth / reference.laneWidth
        let expectedPotOverLane = reference.potWidth / reference.laneWidth
        let expectedLaneOverCloud = reference.laneHeight / reference.cloudHeight
        let expectedDiscardOverPot = reference.discardPileWidth / reference.potWidth

        let playfields: [CGSize] = [
            BoardDesignCanvas.referenceSize,
            CGSize(width: 363, height: 434),
            CGSize(width: 428, height: 707),
            CGSize(width: 320, height: 900),
            CGSize(width: 600, height: 400),
            CGSize(width: 195, height: 270)
        ]

        for playfield in playfields {
            let metrics = BoardLayoutMetrics(playfieldSize: playfield)
            XCTAssertEqual(metrics.cloudWidth / metrics.laneWidth, expectedCloudOverLane, accuracy: tolerance)
            XCTAssertEqual(metrics.potWidth / metrics.laneWidth, expectedPotOverLane, accuracy: tolerance)
            XCTAssertEqual(metrics.laneHeight / metrics.cloudHeight, expectedLaneOverCloud, accuracy: tolerance)
            XCTAssertEqual(metrics.discardPileWidth / metrics.potWidth, expectedDiscardOverPot, accuracy: tolerance)
            XCTAssertEqual(
                metrics.bottomRowBottomInset / metrics.canvasHeight,
                reference.bottomRowBottomInset / BoardDesignCanvas.referenceSize.height,
                accuracy: tolerance
            )
        }
    }

    func testRelativeInsetsStayProportionalAcrossScales() {
        let reference = BoardReferenceMetrics.golden
        let half = BoardLayoutMetrics(playfieldSize: CGSize(width: 195, height: 270))

        XCTAssertEqual(
            half.laneGemStackBottomInset / half.canvasHeight,
            reference.laneGemStackBottomInset / BoardDesignCanvas.referenceSize.height,
            accuracy: tolerance
        )
        XCTAssertEqual(
            half.discardOverlayBottomPadding / half.canvasHeight,
            reference.discardOverlayBottomPadding / BoardDesignCanvas.referenceSize.height,
            accuracy: tolerance
        )
    }
}
