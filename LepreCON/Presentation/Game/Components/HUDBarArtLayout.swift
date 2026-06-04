//
// HUDBarArtLayout.swift
// LepreCON
//
// Proportional anchors for blank top_bar / bottom_bar artwork.
// All overlay text uses these coordinates in the bar’s own width × height space.
//

import SwiftUI

enum HUDBarArtLayout {
    // MARK: - Top bar (leading → trailing: Score | Bag | Magic | Rainbow | Settings ring)

    /// Center X of the left (small) stat well — SCORE.
    static let topScoreCenterX: CGFloat = 0.115
    /// Center X of the second stat well — BAG.
    static let topBagCenterX: CGFloat = 0.285
    /// Center X of the magic circle.
    static let topMagicCenterX: CGFloat = 0.495
    /// Center X of the large right stat well — RAINBOW + progress bar.
    static let topRainbowCenterX: CGFloat = 0.715
    /// Center X of the settings ring on the bar art.
    static let topSettingsCenterX: CGFloat = 0.905

    /// Label row sitting in the upper nameplate of each stat section.
    static let topSectionLabelY: CGFloat = 0.30
    /// Value row in the smaller left/right stat wells.
    static let topSmallValueY: CGFloat = 0.52
    /// Magic label + subtitle block (center circle).
    static let topMagicBlockY: CGFloat = 0.50
    /// Rainbow value row in the large right well.
    static let topRainbowValueY: CGFloat = 0.48
    /// Rainbow progress bar in the large right well.
    static let topRainbowProgressY: CGFloat = 0.62
    /// Progress bar width as a fraction of full bar width.
    static let topRainbowProgressWidthFraction: CGFloat = 0.24

    static let topSettingsButtonSize: CGFloat = 34

    // MARK: - Bottom dock (Undo | Roll | Hand)

    static let dockUndoLabelAnchor = UnitPoint(x: 0.135, y: 0.26)
    static let dockUndoIconAnchor = UnitPoint(x: 0.135, y: 0.50)
    static let dockRollDieAnchor = UnitPoint(x: 0.50, y: 0.42)
    static let dockRollCaptionAnchor = UnitPoint(x: 0.50, y: 0.76)
    static let dockHandLabelAnchor = UnitPoint(x: 0.865, y: 0.26)
    static let dockHandContentAnchor = UnitPoint(x: 0.865, y: 0.58)

    static let dockRollDieSize: CGFloat = 60
}

extension View {
    /// Positions this view’s center at proportional coordinates inside a bar-sized box.
    func hudBarPosition(width: CGFloat, height: CGFloat, anchor: UnitPoint) -> some View {
        let w = max(0, width)
        let h = max(0, height)
        return position(x: w * anchor.x, y: h * anchor.y)
    }

    /// Positions this view’s center at proportional X/Y inside a bar-sized box.
    func hudBarPosition(width: CGFloat, height: CGFloat, centerX: CGFloat, centerY: CGFloat) -> some View {
        hudBarPosition(width: width, height: height, anchor: UnitPoint(x: centerX, y: centerY))
    }
}
