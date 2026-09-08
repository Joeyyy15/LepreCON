//
// DiscardPileContentsOverlay.swift
// LepreCON
//
// Compact discard gem tray anchored below the stationary discard control.
// Overlay only — never resizes lanes, clouds, Pot, or the discard button.
//

import SwiftUI

/// Hand-matching compact discard tray. Viewing only — no domain mutations.
/// Cell layout stays compatible with future selectable retrieval.
struct DiscardPileContentsOverlay: View {
    let gemCounts: [GemCountDisplayItem]
    let discardCount: Int
    let isActiveDestination: Bool
    let panelWidth: CGFloat
    let panelHeight: CGFloat
    var onDismiss: (() -> Void)? = nil

    private var gemSize: CGFloat {
        let scale = BoardLayoutMetrics.discardGemCellScale
        return max(36 * scale, min(GameScreenLayout.handTrayGridGemSize * scale, panelWidth * 0.12 * scale))
    }

    private var cellMinHeight: CGFloat {
        GameScreenLayout.handTrayGridCellMinHeight * BoardLayoutMetrics.discardGemCellScale
    }

    private var headerTitle: String {
        if isActiveDestination {
            return "DISCARD 1 GEM"
        }
        return "DISCARD • \(discardCount)"
    }

    var body: some View {
        VStack(spacing: 0) {
            header

            HandTrayGemGridView(
                gemCounts: gemCounts,
                canPlace: false,
                showsDisabledAppearance: false,
                emptyMessage: "No discarded gems",
                gemSize: gemSize,
                cellMinHeight: cellMinHeight
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .frame(width: panelWidth, height: panelHeight)
        .background(GemTrayPanelChrome.background)
        .overlay {
            GemTrayPanelChrome.borderStroke(isEmphasized: isActiveDestination)
                .padding(1)
        }
        .clipShape(RoundedRectangle(cornerRadius: GemTrayPanelChrome.cornerRadius, style: .continuous))
        .shadow(color: .black.opacity(0.35), radius: 8, x: 0, y: 3)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Discard pile contents, \(discardCount) gems")
    }

    private var header: some View {
        HStack(spacing: 6) {
            Text(headerTitle)
                .font(.system(size: 12, weight: .heavy, design: .rounded))
                .foregroundStyle(
                    isActiveDestination ? BoardStyle.d12GradientTop : HUDFantasyText.labelColor
                )
                .lineLimit(1)
                .minimumScaleFactor(0.85)
                .hudReadableShadow()

            Spacer(minLength: 6)

            if let onDismiss {
                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(BoardStyle.hudValue.opacity(0.9))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Close discard tray")
            }
        }
        .padding(.horizontal, 12)
        .padding(.top, 8)
        .padding(.bottom, 4)
        .frame(height: BoardLayoutMetrics.discardTrayHeaderLogicalHeight, alignment: .center)
    }
}

#Preview("Discard tray empty") {
    DiscardPileContentsOverlay(
        gemCounts: [],
        discardCount: 0,
        isActiveDestination: false,
        panelWidth: 360,
        panelHeight: 76,
        onDismiss: {}
    )
}

#Preview("Discard tray with gems") {
    DiscardPileContentsOverlay(
        gemCounts: [
            GemCountDisplayItem(kind: .red, count: 3),
            GemCountDisplayItem(kind: .gold, count: 2),
            GemCountDisplayItem(kind: .pink, count: 1)
        ],
        discardCount: 6,
        isActiveDestination: true,
        panelWidth: 360,
        panelHeight: 150,
        onDismiss: nil
    )
}
