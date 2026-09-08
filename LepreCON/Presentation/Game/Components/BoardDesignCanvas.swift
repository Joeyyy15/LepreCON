//
// BoardDesignCanvas.swift
// LepreCON
//
// Runtime fit box for uniform board scaling across devices.
//

import CoreGraphics

/// Runtime playfield used to fit the board with uniform scale.
///
/// `referenceSize` (390 × 540) is the measured iPhone 17 Pro gameplay playfield
/// (safe-area GeometryReader). Other devices fit this aspect via uniform scale and
/// centered letterboxing/pillarboxing — not by stretching board elements independently.
///
/// Visual lane/cloud/pot/discard sizes come from `BoardReferenceMetrics.golden`
/// (frozen art geometry), not from regenerating formulas against this fit box.
enum BoardDesignCanvas {
    /// Measured golden-device board playfield; identity fit target (`scale == 1`).
    static let referenceSize = CGSize(width: 390, height: 540)

    /// Width ÷ height of the runtime fit box.
    static var aspectRatio: CGFloat {
        referenceSize.width / referenceSize.height
    }
}

/// Result of fitting `BoardDesignCanvas.referenceSize` inside an available playfield.
struct BoardCanvasFit: Equatable {
    /// Uniform scale applied to the logical canvas.
    let scale: CGFloat
    /// Scaled canvas size in the available coordinate space.
    let size: CGSize
    /// Top-leading origin of the centered fitted canvas inside the available rectangle.
    let origin: CGPoint

    /// Axis-aligned frame of the fitted canvas inside the available playfield.
    var frame: CGRect {
        CGRect(origin: origin, size: size)
    }

    /// Fits the golden runtime canvas into `availableSize`, preserving aspect ratio.
    ///
    /// - Scale is `min(availableWidth / 390, availableHeight / 540)`.
    /// - Unused space becomes centered letterboxing (extra height) or pillarboxing (extra width).
    static func fit(
        in availableSize: CGSize,
        referenceSize: CGSize = BoardDesignCanvas.referenceSize
    ) -> BoardCanvasFit {
        let availableWidth = max(0, availableSize.width)
        let availableHeight = max(0, availableSize.height)
        let referenceWidth = max(1, referenceSize.width)
        let referenceHeight = max(1, referenceSize.height)

        let widthScale = availableWidth / referenceWidth
        let heightScale = availableHeight / referenceHeight
        let scale = min(widthScale, heightScale)

        let fittedWidth = referenceWidth * scale
        let fittedHeight = referenceHeight * scale
        let origin = CGPoint(
            x: (availableWidth - fittedWidth) / 2,
            y: (availableHeight - fittedHeight) / 2
        )

        return BoardCanvasFit(
            scale: scale,
            size: CGSize(width: fittedWidth, height: fittedHeight),
            origin: origin
        )
    }
}
