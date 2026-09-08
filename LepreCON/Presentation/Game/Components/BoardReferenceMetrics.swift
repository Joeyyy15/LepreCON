//
// BoardReferenceMetrics.swift
// LepreCON
//
// Frozen logical board geometry (preferred iPhone 17 Pro visual look).
// Distinct from BoardDesignCanvas.referenceSize, which is the runtime fit box.
//

import CoreGraphics

/// Logical (unscaled) board measurements for the preferred golden visual composition.
///
/// These values were frozen by evaluating the legacy layout formulas at the
/// preferred art canvas (390 × 636). They are **not** recomputed from the runtime
/// fit box (`BoardDesignCanvas.referenceSize` = 390 × 540). Runtime board sizes
/// are `golden × canvasFit.scale`.
struct BoardReferenceMetrics: Equatable {
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

    let topLaneClearance: CGFloat
    let outsideCloudOverhang: CGFloat

    let laneCloudBackgroundOverlap: CGFloat
    let laneGemStackAboveCloudPadding: CGFloat
    let cupScoringBelowHeight: CGFloat

    let laneBackgroundBottomInset: CGFloat
    let laneGemStackBottomInset: CGFloat
    let laneGemStackHeight: CGFloat

    let discardPileWidth: CGFloat
    let discardPileCompactHeight: CGFloat
    let discardOverlayWidth: CGFloat
    let discardOverlayHeight: CGFloat
    let discardOverlayBottomPadding: CGFloat

    /// Art canvas size used to freeze `golden` (preferred visual look).
    /// Not the runtime fit box — see `BoardDesignCanvas.referenceSize`.
    static let artCanvasSize = CGSize(width: 390, height: 636)

    /// Logical downward shift of the whole board composition inside the fit box.
    ///
    /// Art metrics were frozen for `artCanvasSize` (636pt tall). The runtime fit box
    /// is shorter (540). Tuned on iPhone 17 Pro so the highest unicorn marker sits
    /// ~18–24pt below the top HUD bottom (identity scale ≈ 21pt with offset 93).
    static let contentVerticalOffset: CGFloat = 93

    /// Single source of logical geometry for Stage 2+ scaling.
    static let golden: BoardReferenceMetrics = .derived(from: artCanvasSize)

    /// Re-runs the pre-canvas layout formulas against a logical canvas size.
    /// Used only to freeze the golden reference — runtime board sizing uses `golden` × scale.
    static func derived(from size: CGSize) -> BoardReferenceMetrics {
        let width = max(size.width, 1)
        let height = max(size.height, 1)

        let bottomRowBottomInset = height * 0.28
        let bottomSpacing: CGFloat = -8
        let laneInnerPadding: CGFloat = 3
        let cupInnerPadding: CGFloat = 4
        let laneGemStackAboveCloudPadding: CGFloat = 8
        let cupScoringBelowHeight = min(34, height * 0.075)
        let topLaneClearance = max(20, height * 0.05)
        let outsideCloudOverhang: CGFloat = 10
        let laneSpacing: CGFloat = 2

        let lanesRowTargetWidth = width * 0.86
        let laneWidth = floor((lanesRowTargetWidth - laneSpacing * 5) / 6)
        let calculatedLanesRowWidth = 6 * laneWidth + 5 * laneSpacing
        let bottomRowTargetWidth = min(width, calculatedLanesRowWidth + 2 * outsideCloudOverhang)

        var cloudW = width * 0.225
        var potW = width * 0.24
        var cloudH = cloudW * 1.5
        var potH = potW * 1.12

        var calculatedBottomRowWidth = 4 * cloudW + potW + 4 * bottomSpacing

        if calculatedBottomRowWidth < bottomRowTargetWidth {
            let grow = bottomRowTargetWidth / calculatedBottomRowWidth
            cloudW *= grow
            cloudH *= grow
            potW *= grow
            potH *= grow
            calculatedBottomRowWidth = bottomRowTargetWidth
        }

        if calculatedBottomRowWidth > width {
            let shrink = width / calculatedBottomRowWidth
            cloudW *= shrink
            cloudH *= shrink
            potW *= shrink
            potH *= shrink
        }

        let discardPileWidth = potW
        let discardPileCompactHeight = max(44, height * 0.065)
        let discardOverlayWidth = min(width * 0.94, max(potW * 3.2, width * 0.88))
        // Logical overlay height from the golden inset — no absolute 150pt floor.
        // (That floor only mattered when sizing against arbitrary short playfields.)
        let discardOverlayHeight = min(height * 0.34, bottomRowBottomInset * 0.92)
        let discardOverlayBottomPadding = max(4, (bottomRowBottomInset - discardOverlayHeight) * 0.35)

        let bottomCupHeight = max(cloudH, potH)
        let laneCloudBackgroundOverlap = min(bottomCupHeight * 0.42, height * 0.12)
        let laneBackgroundBottomInset = bottomCupHeight - laneCloudBackgroundOverlap
        let laneHeight = max(
            60,
            height - topLaneClearance - bottomRowBottomInset - laneBackgroundBottomInset
        )
        let laneGemStackBottomInset = bottomCupHeight + laneGemStackAboveCloudPadding
        let laneGemStackHeight = max(
            48,
            laneHeight - laneCloudBackgroundOverlap + laneGemStackAboveCloudPadding
        )

        return BoardReferenceMetrics(
            laneWidth: laneWidth,
            laneHeight: laneHeight,
            laneSpacing: laneSpacing,
            cloudWidth: cloudW,
            cloudHeight: cloudH,
            potWidth: potW,
            potHeight: potH,
            bottomSpacing: bottomSpacing,
            laneInnerPadding: laneInnerPadding,
            cupInnerPadding: cupInnerPadding,
            bottomRowBottomInset: bottomRowBottomInset,
            topLaneClearance: topLaneClearance,
            outsideCloudOverhang: outsideCloudOverhang,
            laneCloudBackgroundOverlap: laneCloudBackgroundOverlap,
            laneGemStackAboveCloudPadding: laneGemStackAboveCloudPadding,
            cupScoringBelowHeight: cupScoringBelowHeight,
            laneBackgroundBottomInset: laneBackgroundBottomInset,
            laneGemStackBottomInset: laneGemStackBottomInset,
            laneGemStackHeight: laneGemStackHeight,
            discardPileWidth: discardPileWidth,
            discardPileCompactHeight: discardPileCompactHeight,
            discardOverlayWidth: discardOverlayWidth,
            discardOverlayHeight: discardOverlayHeight,
            discardOverlayBottomPadding: discardOverlayBottomPadding
        )
    }
}
