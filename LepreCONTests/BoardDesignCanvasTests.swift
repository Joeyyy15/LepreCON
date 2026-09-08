//
// BoardDesignCanvasTests.swift
// LepreCONTests
//
// Unit tests for golden board canvas fitting (Stage 1 responsive layout).
//

import XCTest
@testable import LepreCON

final class BoardDesignCanvasTests: XCTestCase {

    private let reference = BoardDesignCanvas.referenceSize
    private let aspectTolerance: CGFloat = 0.000_1

    func testReferenceSizeIsMeasuredGoldenPlayfield() {
        XCTAssertEqual(BoardDesignCanvas.referenceSize.width, 390)
        XCTAssertEqual(BoardDesignCanvas.referenceSize.height, 540)
        XCTAssertEqual(
            BoardDesignCanvas.aspectRatio,
            390 / 540,
            accuracy: aspectTolerance
        )
    }

    func testFitExactReferenceSizeYieldsIdentity() {
        let fit = BoardCanvasFit.fit(in: reference)

        XCTAssertEqual(fit.scale, 1, accuracy: aspectTolerance)
        XCTAssertEqual(fit.size.width, 390, accuracy: aspectTolerance)
        XCTAssertEqual(fit.size.height, 540, accuracy: aspectTolerance)
        XCTAssertEqual(fit.origin.x, 0, accuracy: aspectTolerance)
        XCTAssertEqual(fit.origin.y, 0, accuracy: aspectTolerance)
        XCTAssertEqual(fit.frame, CGRect(origin: .zero, size: reference))
    }

    func testFitTallerAvailableRectangleIsWidthLimitedWithVerticalLetterboxing() {
        // Same width as reference, extra height → scale 1, centered vertically.
        let available = CGSize(width: 390, height: 800)
        let fit = BoardCanvasFit.fit(in: available)

        XCTAssertEqual(fit.scale, 1, accuracy: aspectTolerance)
        XCTAssertEqual(fit.size.width, 390, accuracy: aspectTolerance)
        XCTAssertEqual(fit.size.height, 540, accuracy: aspectTolerance)
        XCTAssertEqual(fit.origin.x, 0, accuracy: aspectTolerance)
        XCTAssertEqual(fit.origin.y, (800 - 540) / 2, accuracy: aspectTolerance)
        assertPreservesReferenceAspect(fit)
    }

    func testFitWiderAvailableRectangleIsHeightLimitedWithHorizontalPillarboxing() {
        // Same height as reference, extra width → scale 1, centered horizontally.
        let available = CGSize(width: 500, height: 540)
        let fit = BoardCanvasFit.fit(in: available)

        XCTAssertEqual(fit.scale, 1, accuracy: aspectTolerance)
        XCTAssertEqual(fit.size.width, 390, accuracy: aspectTolerance)
        XCTAssertEqual(fit.size.height, 540, accuracy: aspectTolerance)
        XCTAssertEqual(fit.origin.x, (500 - 390) / 2, accuracy: aspectTolerance)
        XCTAssertEqual(fit.origin.y, 0, accuracy: aspectTolerance)
        assertPreservesReferenceAspect(fit)
    }

    func testFitSmallerRectangleDownscalesUniformly() {
        let available = CGSize(width: 195, height: 270) // exactly half of 390×540
        let fit = BoardCanvasFit.fit(in: available)

        XCTAssertEqual(fit.scale, 0.5, accuracy: aspectTolerance)
        XCTAssertEqual(fit.size.width, 195, accuracy: aspectTolerance)
        XCTAssertEqual(fit.size.height, 270, accuracy: aspectTolerance)
        XCTAssertEqual(fit.origin.x, 0, accuracy: aspectTolerance)
        XCTAssertEqual(fit.origin.y, 0, accuracy: aspectTolerance)
        assertPreservesReferenceAspect(fit)
        XCTAssertGreaterThanOrEqual(fit.size.width, 0)
        XCTAssertGreaterThanOrEqual(fit.size.height, 0)
    }

    func testFitSmallerNonMatchingAspectPreservesRatioAndCenters() {
        let available = CGSize(width: 300, height: 300)
        let fit = BoardCanvasFit.fit(in: available)

        // Height-limited: 300/540 < 300/390
        let expectedScale = CGFloat(300) / CGFloat(540)
        XCTAssertEqual(fit.scale, expectedScale, accuracy: aspectTolerance)
        XCTAssertEqual(fit.size.width, CGFloat(390) * expectedScale, accuracy: aspectTolerance)
        XCTAssertEqual(fit.size.height, 300, accuracy: aspectTolerance)
        XCTAssertEqual(fit.origin.x, (300 - fit.size.width) / 2, accuracy: aspectTolerance)
        XCTAssertEqual(fit.origin.y, 0, accuracy: aspectTolerance)
        assertPreservesReferenceAspect(fit)
    }

    func testFitAspectInvariantAcrossRepresentativeSizes() {
        let sizes: [CGSize] = [
            CGSize(width: 390, height: 540),
            CGSize(width: 363, height: 434),
            CGSize(width: 428, height: 707),
            CGSize(width: 320, height: 900),
            CGSize(width: 600, height: 400),
            CGSize(width: 1, height: 1)
        ]

        for available in sizes {
            let fit = BoardCanvasFit.fit(in: available)
            assertPreservesReferenceAspect(fit, file: #file, line: #line)
            XCTAssertGreaterThanOrEqual(fit.scale, 0)
            XCTAssertGreaterThanOrEqual(fit.size.width, 0)
            XCTAssertGreaterThanOrEqual(fit.size.height, 0)
            XCTAssertLessThanOrEqual(fit.size.width, available.width + aspectTolerance)
            XCTAssertLessThanOrEqual(fit.size.height, available.height + aspectTolerance)
        }
    }

    func testBoardLayoutMetricsExposesCanvasFitAtReferencePlayfield() {
        let playfield = CGSize(width: 390, height: 540)
        let metrics = BoardLayoutMetrics(playfieldSize: playfield)

        XCTAssertEqual(metrics.canvasFit.scale, 1, accuracy: aspectTolerance)
        XCTAssertEqual(metrics.canvasFit.size.width, 390, accuracy: aspectTolerance)
        XCTAssertEqual(metrics.canvasFit.size.height, 540, accuracy: aspectTolerance)
        XCTAssertEqual(metrics.playfieldWidth, 390)
        XCTAssertEqual(metrics.playfieldHeight, 540)
        XCTAssertEqual(metrics.canvasWidth, 390, accuracy: aspectTolerance)
        XCTAssertEqual(metrics.laneWidth, BoardReferenceMetrics.golden.laneWidth, accuracy: aspectTolerance)
    }

    private func assertPreservesReferenceAspect(
        _ fit: BoardCanvasFit,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        guard fit.size.height > 0 else {
            XCTFail("Fitted height should be positive", file: file, line: line)
            return
        }
        XCTAssertEqual(
            fit.size.width / fit.size.height,
            BoardDesignCanvas.aspectRatio,
            accuracy: aspectTolerance,
            file: file,
            line: line
        )
    }
}
