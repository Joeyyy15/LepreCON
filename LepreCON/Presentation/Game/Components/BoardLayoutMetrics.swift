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
        verticalSpacing = 14 * scale
        laneInnerPadding = 4 * scale
        cupInnerPadding = 5 * scale
    }
}

enum BoardLayout {
    /// Natural design size before scaling to fit the device.
    static let designWidth: CGFloat = 340
    static let designHeight: CGFloat = 332

    /// Keeps the board large but fully visible in the middle zone on phone screens.
    static let maximumScale: CGFloat = 1.05

    static func scale(for containerSize: CGSize) -> CGFloat {
        let widthScale = (containerSize.width - 16) / designWidth
        let heightScale = (containerSize.height - 16) / designHeight
        return min(widthScale, heightScale, maximumScale)
    }

    static func scaledSize(for containerSize: CGSize, scale: CGFloat) -> CGSize {
        CGSize(width: designWidth * scale, height: designHeight * scale)
    }
}
