//
// HUDBarArtLayout.swift
// LepreCON
//
// Proportional anchors for blank top_bar / bottom_bar artwork.
// All overlay text uses these coordinates in the bar’s own width × height space.
//
// Example:
// centerX = 0.50 means halfway across the bar.
// centerY = 0.50 means halfway down the bar.
//
// Keep these values centralized here so HUD alignment can be tuned without
// scattering random offsets across multiple SwiftUI views.
//

import SwiftUI

enum HUDBarArtLayout {
    // MARK: - Top bar
    // Visual order: Score | Bag | Magic | Rainbow | Settings

    /// Center X of the left small stat well — SCORE.
    static let topScoreCenterX: CGFloat = 0.18

    /// Center X of the second small stat well — BAG.
    static let topBagCenterX: CGFloat = 0.33

    /// Center X of the middle magic circle.
    static let topMagicCenterX: CGFloat = 0.487

    /// Center X of the large right stat well — RAINBOW + progress bar.
    static let topRainbowCenterX: CGFloat = 0.715

    /// Center X of the settings ring on the right side of the top bar.
    /// Slightly pulled left so the custom settings icon sits inside the ring better.
    static let topSettingsCenterX: CGFloat = 0.931

    /// Label row sitting inside the upper nameplate of each stat section.
    /// Increased from 0.30 so SCORE/BAG/RAINBOW sit inside the art instead of above it.
    static let topSectionLabelY: CGFloat = 0.36

    /// Value row in the smaller left stat wells.
    /// Increased from 0.52 so values sit more centered inside the lower wells.
    static let topSmallValueY: CGFloat = 0.54

    /// Magic label + subtitle block inside the center circle.
    /// Slightly lower so MAGIC / Coming Soon feel centered in the circle.
    static let topMagicBlockY: CGFloat = 0.46

    /// Rainbow value row in the large right stat well.
    static let topRainbowValueY: CGFloat = 0.54

    /// Rainbow progress bar row inside the large right stat well.
    static let topRainbowProgressY: CGFloat = 0.68

    /// Progress bar width as a fraction of the full top bar width.
    /// This keeps the progress bar inside the large Rainbow section.
    static let topRainbowProgressWidthFraction: CGFloat = 0.24

    /// Size for the custom Image("settings") button.
    static let topSettingsButtonSize: CGFloat = 40.5

    // MARK: - Bottom dock
    // Visual order: Undo | Roll D12 | Hand

    /// UNDO label position inside the left dock plate.
    static let dockUndoLabelAnchor = UnitPoint(x: 0.2, y: 0.29)

    /// Undo icon/button position inside the left dock panel.
    static let dockUndoIconAnchor = UnitPoint(x: 0.195, y: 0.52)

    /// D12 die position inside the center dock panel.
    static let dockRollDieAnchor = UnitPoint(x: 0.50, y: 0.455)

    /// ROLL D12 text position inside the lower center plate.
    static let dockRollCaptionAnchor = UnitPoint(x: 0.50, y: 0.79)

    /// HAND label position inside the right dock plate.
    static let dockHandLabelAnchor = UnitPoint(x: 0.81, y: 0.29)

    /// Hand gems / empty state position inside the right dock panel.
    static let dockHandContentAnchor = UnitPoint(x: 0.81, y: 0.9)

    /// D12 die size used in the bottom dock.
    static let dockRollDieSize: CGFloat = 57
}

extension View {
    /// Positions this view’s center at proportional coordinates inside a bar-sized box.
    ///
    /// Example:
    /// anchor x: 0.50, y: 0.50 places the view in the exact center of the bar.
    func hudBarPosition(width: CGFloat, height: CGFloat, anchor: UnitPoint) -> some View {
        let w = max(0, width)
        let h = max(0, height)
        return position(x: w * anchor.x, y: h * anchor.y)
    }

    /// Convenience overload for positioning with separate X/Y values.
    func hudBarPosition(width: CGFloat, height: CGFloat, centerX: CGFloat, centerY: CGFloat) -> some View {
        hudBarPosition(width: width, height: height, anchor: UnitPoint(x: centerX, y: centerY))
    }
}
