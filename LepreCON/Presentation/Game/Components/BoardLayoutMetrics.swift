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
    static let discardTrayHeaderLogicalHeight: CGFloat = 16

    /// Empty-tray body height below the header (logical, before scale).
    static let discardTrayEmptyBodyLogicalHeight: CGFloat = 26

    /// Discard gem-cell size vs Hand — dense enough to show all kinds at a glance.
    static let discardGemCellScale: CGFloat = 0.60

    /// Max columns before wrapping (6 → all 11 kinds fit in 2 rows on phone).
    static let discardMaxColumns: Int = 6

    /// Soft upper bound on visible rows; dock max height is the hard cap.
    static let discardMaxVisibleRows: Int = 3

    /// Narrowest non-empty panel (fits header + close).
    static let discardPanelMinWidth: CGFloat = 132

    /// Compact empty-state panel width.
    static let discardEmptyPanelWidth: CGFloat = 148

    /// Floor for column stride so dense cells stay readable.
    static let discardGridColumnMinimumFloor: CGFloat = 44

    static let discardGridSpacing: CGFloat = 2
    static let discardGridHorizontalPadding: CGFloat = 8
    static let discardGridVerticalPadding: CGFloat = 0

    /// Stable gem image size (not derived from a full-bleed panel width).
    static func discardContentGemSize(scale: CGFloat = 1) -> CGFloat {
        let s = max(scale, 0.01)
        return GameScreenLayout.handTrayGridGemSize * discardGemCellScale * s
    }

    /// Discard gem image size for a given tray panel width.
    static func discardGemSize(panelWidth: CGFloat, scale: CGFloat = 1) -> CGFloat {
        let s = max(scale, 0.01)
        let base = discardContentGemSize(scale: s)
        let narrowCap = max(22 * s, panelWidth * 0.40)
        return min(base, narrowCap)
    }

    /// Compact cell height — count badge overlays the gem to save vertical space.
    static func discardGemCellMinHeight(gemSize: CGFloat) -> CGFloat {
        gemSize
    }

    /// Outer column stride used for content-driven width / wrapping.
    static func discardCellOuterWidth(gemSize: CGFloat, scale: CGFloat = 1) -> CGFloat {
        let s = max(scale, 0.01)
        return max(gemSize + 8 * s, discardGridColumnMinimumFloor * s)
    }

    /// Adaptive column minimum used by the discard grouped grid.
    static func discardGridColumnMinimum(gemSize: CGFloat) -> CGFloat {
        discardCellOuterWidth(gemSize: gemSize)
    }

    /// Columns used for a content-sized panel of `panelWidth`.
    static func discardColumnCount(
        gemKindCount: Int,
        panelWidth: CGFloat,
        scale: CGFloat = 1
    ) -> Int {
        guard gemKindCount > 0 else { return 1 }
        let s = max(scale, 0.01)
        let gemSize = discardGemSize(panelWidth: panelWidth, scale: s)
        let cellW = discardCellOuterWidth(gemSize: gemSize, scale: s)
        let spacing = discardGridSpacing * s
        let hPad = discardGridHorizontalPadding * s
        let fitted = max(1, Int(floor((panelWidth - hPad + spacing) / (cellW + spacing))))
        return min(gemKindCount, discardMaxColumns, fitted)
    }

    /// Content-driven panel width from grouped kind count (clamped to `maxWidth`).
    static func discardPanelWidth(
        gemKindCount: Int,
        maxWidth: CGFloat,
        scale: CGFloat = 1
    ) -> CGFloat {
        let s = max(scale, 0.01)
        if gemKindCount <= 0 {
            return min(maxWidth, discardEmptyPanelWidth * s)
        }

        let gemSize = discardContentGemSize(scale: s)
        let cellW = discardCellOuterWidth(gemSize: gemSize, scale: s)
        let spacing = discardGridSpacing * s
        let hPad = discardGridHorizontalPadding * s
        let columns = min(gemKindCount, discardMaxColumns)
        let content = CGFloat(columns) * cellW
            + CGFloat(max(0, columns - 1)) * spacing
            + hPad
        return min(maxWidth, max(discardPanelMinWidth * s, content))
    }

    /// Uncapped height for `visibleRowCount` rows inside `panelWidth`.
    static func discardHeightForVisibleRows(
        visibleRowCount: Int,
        panelWidth: CGFloat,
        scale: CGFloat = 1
    ) -> CGFloat {
        let s = max(scale, 0.01)
        let header = discardTrayHeaderLogicalHeight * s
        let rows = max(visibleRowCount, 0)
        if rows == 0 {
            return header + discardTrayEmptyBodyLogicalHeight * s
        }

        let gemSize = discardGemSize(panelWidth: panelWidth, scale: s)
        let cellHeight = discardGemCellMinHeight(gemSize: gemSize)
        let rowSpacing = discardGridSpacing * s
        let gridPadding = discardGridVerticalPadding * s
        let rowsHeight = CGFloat(rows) * cellHeight
            + CGFloat(max(0, rows - 1)) * rowSpacing
        return header + gridPadding + rowsHeight
    }

    /// Ideal content height for all rows (may exceed the on-screen max → scroll).
    static func idealDiscardTrayHeight(
        gemKindCount: Int,
        panelWidth: CGFloat,
        scale: CGFloat,
        gemCellScale: CGFloat = discardGemCellScale
    ) -> CGFloat {
        _ = gemCellScale
        if gemKindCount <= 0 {
            return discardHeightForVisibleRows(visibleRowCount: 0, panelWidth: panelWidth, scale: scale)
        }
        let columns = discardColumnCount(
            gemKindCount: gemKindCount,
            panelWidth: panelWidth,
            scale: scale
        )
        let rowsNeeded = Int(ceil(Double(gemKindCount) / Double(max(columns, 1))))
        return discardHeightForVisibleRows(
            visibleRowCount: rowsNeeded,
            panelWidth: panelWidth,
            scale: scale
        )
    }

    /// Whether the full grouped grid fits in `maxHeight` without vertical scrolling.
    static func discardGridFitsWithoutScrolling(
        gemKindCount: Int,
        panelWidth: CGFloat,
        maxHeight: CGFloat,
        scale: CGFloat = 1
    ) -> Bool {
        guard gemKindCount > 0, maxHeight > 0 else { return true }
        let ideal = idealDiscardTrayHeight(
            gemKindCount: gemKindCount,
            panelWidth: panelWidth,
            scale: scale
        )
        return ideal <= maxHeight + 0.5
    }

    /// Content-sized panel height, capped by `maxHeight` (dock clearance).
    ///
    /// Uses the full row count when it fits; otherwise caps at the dock max (scroll).
    static func discardPanelHeight(
        gemKindCount: Int,
        panelWidth: CGFloat,
        maxHeight: CGFloat,
        scale: CGFloat = 1
    ) -> CGFloat {
        if maxHeight <= 0 { return 0 }

        if gemKindCount <= 0 {
            let empty = discardHeightForVisibleRows(
                visibleRowCount: 0,
                panelWidth: panelWidth,
                scale: scale
            )
            return min(maxHeight, empty)
        }

        let columns = discardColumnCount(
            gemKindCount: gemKindCount,
            panelWidth: panelWidth,
            scale: scale
        )
        let rowsNeeded = Int(ceil(Double(gemKindCount) / Double(max(columns, 1))))
        let visibleRows = min(max(rowsNeeded, 1), discardMaxVisibleRows)
        let content = discardHeightForVisibleRows(
            visibleRowCount: visibleRows,
            panelWidth: panelWidth,
            scale: scale
        )
        return min(maxHeight, content)
    }

    /// Fixed tray top in playfield coordinates (discard button bottom + gap).
    /// Stable when height changes — only the bottom edge moves.
    var discardTrayFixedTopInPlayfield: CGFloat {
        discardControlBottomInCanvas
            + contentVerticalOffset
            + Self.discardTrayGapBelowControl
    }

    /// Maximum tray height that still clears the dock (`nil` → uncapped for previews).
    func discardTrayMaxHeight(playfieldBottomLimit: CGFloat?) -> CGFloat {
        guard let limit = playfieldBottomLimit else {
            return 10_000
        }
        return max(0, limit - discardTrayFixedTopInPlayfield)
    }

    /// Content-driven tray height, never automatically filling to the dock.
    func discardTrayHeight(
        gemKindCount: Int,
        panelWidth: CGFloat,
        playfieldBottomLimit: CGFloat?
    ) -> CGFloat {
        Self.discardPanelHeight(
            gemKindCount: gemKindCount,
            panelWidth: panelWidth,
            maxHeight: discardTrayMaxHeight(playfieldBottomLimit: playfieldBottomLimit),
            scale: canvasFit.scale
        )
    }

    /// Content-driven tray width, clamped to the board overlay max.
    func discardTrayWidth(gemKindCount: Int) -> CGFloat {
        Self.discardPanelWidth(
            gemKindCount: gemKindCount,
            maxWidth: discardOverlayWidth,
            scale: canvasFit.scale
        )
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
