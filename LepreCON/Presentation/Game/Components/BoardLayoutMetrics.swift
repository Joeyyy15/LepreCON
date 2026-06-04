//
// BoardLayoutMetrics.swift
// LepreCON
//
// Layout sizes for the gameplay board, derived from the available playfield size.
//

import SwiftUI

/// Measurements for the connected rainbow + cloud/pot board inside the playfield.
struct BoardLayoutMetrics {
    let playfieldWidth: CGFloat
    let playfieldHeight: CGFloat

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

    /// Space reserved at the top of the playfield so lane tops stop below the HUD.
    let topLaneClearance: CGFloat

    /// How far outer cloud edges should extend past the outside rainbow lanes.
    let outsideCloudOverhang: CGFloat

    let laneCloudBackgroundOverlap: CGFloat
    let laneGemStackAboveCloudPadding: CGFloat
    let cupScoringBelowHeight: CGFloat

    let laneBackgroundBottomInset: CGFloat
    let laneGemStackBottomInset: CGFloat
    let laneGemStackHeight: CGFloat

    /// Sizes the board to fill the playfield rectangle between HUD and dock.
    init(playfieldSize size: CGSize) {
        let width = max(size.width, 1)
        let height = max(size.height, 1)

        playfieldWidth = width
        playfieldHeight = height

        // Keeps the cloud/pot row lifted above the bottom dock.
        bottomRowBottomInset = height * 0.19

        // Negative spacing allows the cloud artwork to overlap slightly,
        // making the cloud row feel fuller and more connected.
        bottomSpacing = -8

        laneInnerPadding = 3
        cupInnerPadding = 4
        laneGemStackAboveCloudPadding = 8
        cupScoringBelowHeight = min(34, height * 0.075)

        topLaneClearance = max(20, height * 0.05)
        outsideCloudOverhang = 10

        // Rainbow lanes stay centered and slightly narrower than the cloud row.
        laneSpacing = 2

        let lanesRowTargetWidth = width * 0.86
        // Floor width so six equal frames tile with consistent inter-lane gaps.
        laneWidth = floor((lanesRowTargetWidth - laneSpacing * 5) / 6)

        let calculatedLanesRowWidth = 6 * laneWidth + 5 * laneSpacing

        // The cloud row should extend past the outside rainbow lanes.
        let bottomRowTargetWidth = min(
            width,
            calculatedLanesRowWidth + 2 * outsideCloudOverhang
        )

        // Size clouds primarily from the available width.
        // Five containers must fit in one row, so width is the limiting factor.
        //
        // Clouds are wider and shorter.
        // The pot is slightly narrower but taller.
        var cloudW = width * 0.225
        var potW = width * 0.24

        var cloudH = cloudW * 1.5
        var potH = potW * 1.12

        var calculatedBottomRowWidth =
            4 * cloudW +
            potW +
            4 * bottomSpacing

        // Grow the row if it is not wide enough to extend past the lanes.
        if calculatedBottomRowWidth < bottomRowTargetWidth {
            let grow = bottomRowTargetWidth / calculatedBottomRowWidth

            cloudW *= grow
            cloudH *= grow
            potW *= grow
            potH *= grow

            calculatedBottomRowWidth = bottomRowTargetWidth
        }

        // Shrink only as a safety fallback if the row exceeds the playfield.
        if calculatedBottomRowWidth > width {
            let shrink = width / calculatedBottomRowWidth

            cloudW *= shrink
            cloudH *= shrink
            potW *= shrink
            potH *= shrink
        }

        cloudWidth = cloudW
        cloudHeight = cloudH
        potWidth = potW
        potHeight = potH

        let bottomCupHeight = max(cloudHeight, potHeight)

        // Lets the colored lane backgrounds tuck behind the clouds and pot.
        laneCloudBackgroundOverlap = min(
            bottomCupHeight * 0.42,
            height * 0.12
        )

        laneBackgroundBottomInset =
            bottomCupHeight - laneCloudBackgroundOverlap

        // Lane tops stop below the HUD while growing upward from the cloud row.
        laneHeight = max(
            60,
            height
                - topLaneClearance
                - bottomRowBottomInset
                - laneBackgroundBottomInset
        )

        // Lane gems stay above the clouds instead of being hidden behind them.
        laneGemStackBottomInset =
            bottomCupHeight + laneGemStackAboveCloudPadding

        laneGemStackHeight = max(
            48,
            laneHeight
                - laneCloudBackgroundOverlap
                + laneGemStackAboveCloudPadding
        )
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
}

enum BoardLayout {
    static let boardFitMargin: CGFloat = 0

    /// Fixed design used only by SwiftUI previews.
    static var previewMetrics: BoardLayoutMetrics {
        BoardLayoutMetrics(
            playfieldSize: CGSize(width: 360, height: 420)
        )
    }
}
