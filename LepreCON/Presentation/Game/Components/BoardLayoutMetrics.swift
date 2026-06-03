//
// BoardLayoutMetrics.swift
// LepreCON
//
// Scaled layout sizes for the gameplay board on different screen widths.
//

import SwiftUI

/// Responsive measurements derived from the board scale factor.
struct BoardLayoutMetrics {
    let laneWidth: CGFloat
    let laneHeight: CGFloat
    let laneSpacing: CGFloat
    let cloudWidth: CGFloat
    let cloudHeight: CGFloat
    let potWidth: CGFloat
    let potHeight: CGFloat
    let bottomSpacing: CGFloat
    let verticalSpacing: CGFloat
    let laneInnerPadding: CGFloat
    let cupInnerPadding: CGFloat

    init(scale: CGFloat) {
        laneWidth = 40 * scale
        laneHeight = 210 * scale
        laneSpacing = 6 * scale
        cloudWidth = 62 * scale
        cloudHeight = 52 * scale
        potWidth = 78 * scale
        potHeight = 66 * scale
        bottomSpacing = 4 * scale
        verticalSpacing = 12 * scale
        laneInnerPadding = 4 * scale
        cupInnerPadding = 5 * scale
    }

    var lanesRowWidth: CGFloat {
        6 * laneWidth + 5 * laneSpacing
    }

    var bottomRowWidth: CGFloat {
        4 * cloudWidth + potWidth + 4 * bottomSpacing
    }

    var playfieldWidth: CGFloat {
        max(lanesRowWidth, bottomRowWidth)
    }
}

enum BoardLayout {
    static let designHeight: CGFloat = 318

    static let maximumScale: CGFloat = 1.05
    static let boardFitMargin: CGFloat = 2

    /// Matches the widest row (cloud/pot row) at scale 1.0.
    static var designWidth: CGFloat {
        BoardLayoutMetrics(scale: 1).playfieldWidth
    }

    static func playfieldWidth(scale: CGFloat) -> CGFloat {
        BoardLayoutMetrics(scale: scale).playfieldWidth
    }

    static func scale(for containerSize: CGSize) -> CGFloat {
        let widthScale = (containerSize.width - boardFitMargin) / designWidth
        let heightScale = (containerSize.height - boardFitMargin) / designHeight
        return min(widthScale, heightScale, maximumScale)
    }

    static func scaledSize(for containerSize: CGSize, scale: CGFloat) -> CGSize {
        CGSize(
            width: playfieldWidth(scale: scale),
            height: designHeight * scale
        )
    }
}
