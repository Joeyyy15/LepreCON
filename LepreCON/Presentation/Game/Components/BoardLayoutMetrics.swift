//
// BoardLayoutMetrics.swift
// LepreCON
//
// Scaled board geometry: golden logical metrics × uniform canvas fit scale.
//

import SwiftUI

/// Measurements for the connected rainbow + cloud/pot board inside the playfield.
///
/// Board-local sizes come from `BoardReferenceMetrics.golden` multiplied by
/// `canvasFit.scale`. Elements stay in the fitted canvas; letterbox/pillarbox
/// margins remain empty outside `canvasFit.frame`.
struct BoardLayoutMetrics {
    /// Available playfield from `GameBoardView` (may be larger than the canvas).
    let playfieldWidth: CGFloat
    let playfieldHeight: CGFloat

    /// How the golden runtime fit box (390 × 540) maps into this playfield.
    let canvasFit: BoardCanvasFit

    let laneWidth: CGFloat
    let laneHeight: CGFloat
    let laneSpacing: CGFloat

    let cloudWidth: CGFloat
    let cloudHeight: CGFloat
    let potWidth: CGFloat
    let potHeight: CGFloat

    let bottomSpacing: CGFloat
    let laneInnerPadding: CGFloat
    let cupInnerPadding: CGFloat
    let bottomRowBottomInset: CGFloat

    /// Space reserved at the top of the canvas so lane tops stop below the HUD band.
    let topLaneClearance: CGFloat

    /// How far outer cloud edges should extend past the outside rainbow lanes.
    let outsideCloudOverhang: CGFloat

    let laneCloudBackgroundOverlap: CGFloat
    let laneGemStackAboveCloudPadding: CGFloat
    let cupScoringBelowHeight: CGFloat

    let laneBackgroundBottomInset: CGFloat
    let laneGemStackBottomInset: CGFloat
    let laneGemStackHeight: CGFloat

    /// Width for the discard pile control under the Pot of Gold.
    let discardPileWidth: CGFloat
    /// Compact discard control height under the pot.
    let discardPileCompactHeight: CGFloat
    /// Wide overlay panel width for discard contents (does not affect board layout).
    let discardOverlayWidth: CGFloat
    /// Wide overlay panel height for discard contents.
    let discardOverlayHeight: CGFloat
    /// Bottom padding that anchors the overlay beneath the stationary discard control.
    let discardOverlayBottomPadding: CGFloat

    /// Scaled downward shift of the entire board composition inside the canvas.
    let contentVerticalOffset: CGFloat

    /// Width of the fitted board canvas (reference width × scale).
    var canvasWidth: CGFloat { canvasFit.size.width }

    /// Height of the fitted board canvas (reference height × scale).
    var canvasHeight: CGFloat { canvasFit.size.height }

    /// Fits golden board geometry into the available playfield via uniform scale.
    init(playfieldSize size: CGSize) {
        let width = max(size.width, 1)
        let height = max(size.height, 1)

        playfieldWidth = width
        playfieldHeight = height

        let fit = BoardCanvasFit.fit(in: CGSize(width: width, height: height))
        canvasFit = fit

        let reference = BoardReferenceMetrics.golden
        let scale = fit.scale

        laneWidth = reference.laneWidth * scale
        laneHeight = reference.laneHeight * scale
        laneSpacing = reference.laneSpacing * scale

        cloudWidth = reference.cloudWidth * scale
        cloudHeight = reference.cloudHeight * scale
        potWidth = reference.potWidth * scale
        potHeight = reference.potHeight * scale

        bottomSpacing = reference.bottomSpacing * scale
        laneInnerPadding = reference.laneInnerPadding * scale
        cupInnerPadding = reference.cupInnerPadding * scale
        bottomRowBottomInset = reference.bottomRowBottomInset * scale

        topLaneClearance = reference.topLaneClearance * scale
        outsideCloudOverhang = reference.outsideCloudOverhang * scale

        laneCloudBackgroundOverlap = reference.laneCloudBackgroundOverlap * scale
        laneGemStackAboveCloudPadding = reference.laneGemStackAboveCloudPadding * scale
        cupScoringBelowHeight = reference.cupScoringBelowHeight * scale

        laneBackgroundBottomInset = reference.laneBackgroundBottomInset * scale
        laneGemStackBottomInset = reference.laneGemStackBottomInset * scale
        laneGemStackHeight = reference.laneGemStackHeight * scale

        discardPileWidth = reference.discardPileWidth * scale
        discardPileCompactHeight = reference.discardPileCompactHeight * scale
        discardOverlayWidth = reference.discardOverlayWidth * scale
        discardOverlayHeight = reference.discardOverlayHeight * scale
        discardOverlayBottomPadding = reference.discardOverlayBottomPadding * scale

        contentVerticalOffset = BoardReferenceMetrics.contentVerticalOffset * scale
    }

    var lanesRowWidth: CGFloat {
        6 * laneWidth + 5 * laneSpacing
    }

    var bottomRowWidth: CGFloat {
        4 * cloudWidth + potWidth + 4 * bottomSpacing
    }

    var bottomRowCupHeight: CGFloat {
        max(cloudHeight, potHeight)
    }

    var bottomRowTotalHeight: CGFloat {
        bottomRowCupHeight + cupScoringBelowHeight
    }

    /// Compact discard control bottom edge in canvas coordinates (before content offset).
    var discardControlBottomInCanvas: CGFloat {
        canvasHeight - bottomRowBottomInset
    }

    /// Compact discard control top edge in canvas coordinates (before content offset).
    var discardControlTopInCanvas: CGFloat {
        discardControlBottomInCanvas - discardPileCompactHeight
    }

    /// Gap between the compact discard control bottom and the tray top.
    static let discardTrayGapBelowControl: CGFloat = 4

    /// Compact tray header height (logical, before scale).
    static let discardTrayHeaderLogicalHeight: CGFloat = 32

    /// Empty-tray body height below the header (logical, before scale).
    static let discardTrayEmptyBodyLogicalHeight: CGFloat = 44

    /// Modest gem-cell reduction vs Hand so more kinds fit in the dock-capped tray.
    static let discardGemCellScale: CGFloat = 0.9

    /// Ideal compact discard-tray height from grouped gem kind count (uncapped).
    ///
    /// Used for tests and for understanding content needs; runtime height fills
    /// available space below the fixed tray top down to the dock limit.
    static func idealDiscardTrayHeight(
        gemKindCount: Int,
        panelWidth: CGFloat,
        scale: CGFloat,
        gemCellScale: CGFloat = discardGemCellScale
    ) -> CGFloat {
        let s = max(scale, 0.01)
        let g = max(gemCellScale, 0.01)
        let header = discardTrayHeaderLogicalHeight * s
        if gemKindCount <= 0 {
            return header + discardTrayEmptyBodyLogicalHeight * s
        }

        let gemSize = max(
            36 * s * g,
            min(GameScreenLayout.handTrayGridGemSize * s * g, panelWidth * 0.12 * g)
        )
        let minColumnWidth = gemSize + 28 * s * g
        let horizontalPadding = 24 * s
        let columns = max(1, Int(floor((panelWidth - horizontalPadding) / minColumnWidth)))
        let rowsNeeded = Int(ceil(Double(gemKindCount) / Double(columns)))
        let visibleRows = min(max(rowsNeeded, 1), 2)

        let cellHeight = (GameScreenLayout.handTrayGridCellMinHeight * g + 16 * g) * s
        let rowSpacing = 10 * s
        let gridPadding = 16 * s
        let rowsHeight = CGFloat(visibleRows) * cellHeight
            + CGFloat(max(0, visibleRows - 1)) * rowSpacing

        return header + gridPadding + rowsHeight
    }

    /// Fixed tray top in playfield coordinates (discard button bottom + gap).
    /// This must stay stable when height changes — only the bottom edge moves.
    var discardTrayFixedTopInPlayfield: CGFloat {
        discardControlBottomInCanvas
            + contentVerticalOffset
            + Self.discardTrayGapBelowControl
    }

    /// Downward tray height with **fixed top**, bottom at `playfieldBottomLimit`.
    ///
    /// `playfieldBottomLimit` is playfield Y of (dock top − clearance).
    /// Height grows only by moving the bottom edge down; never negative.
    func discardTrayHeight(
        gemKindCount: Int,
        playfieldBottomLimit: CGFloat
    ) -> CGFloat {
        // gemKindCount reserved for future content-min policies; height fills to dock.
        _ = gemKindCount
        return max(0, playfieldBottomLimit - discardTrayFixedTopInPlayfield)
    }

    /// Bottom padding that keeps tray top fixed while `height` extends the bottom edge.
    func discardTrayBottomPadding(forHeight height: CGFloat) -> CGFloat {
        canvasHeight
            - discardControlBottomInCanvas
            - Self.discardTrayGapBelowControl
            - height
    }
}

enum BoardLayout {
    static let boardFitMargin: CGFloat = 0

    /// Fixed design used only by SwiftUI previews.
    static var previewMetrics: BoardLayoutMetrics {
        BoardLayoutMetrics(
            playfieldSize: BoardDesignCanvas.referenceSize
        )
    }
}
