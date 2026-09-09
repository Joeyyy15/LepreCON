//
// DiscardPileContentsOverlay.swift
// LepreCON
//
// Compact discard gem tray anchored below the stationary discard control.
// Overlay only — never resizes lanes, clouds, Pot, or the discard button.
//

import SwiftUI

/// Content-sized discard tray: dense grouped-by-kind grid with scroll only when needed.
/// Viewing only — no domain mutations. Cells stay selection-ready for later retrieval.
struct DiscardPileContentsOverlay: View {
    let gemCounts: [GemCountDisplayItem]
    let discardCount: Int
    let isActiveDestination: Bool
    let panelWidth: CGFloat
    let panelHeight: CGFloat
    var gridColumnCount: Int = 1
    /// When false, the full grid is shown without vertical scrolling.
    var allowsScrolling: Bool = false
    var onDismiss: (() -> Void)? = nil

    private var gemSize: CGFloat {
        BoardLayoutMetrics.discardGemSize(panelWidth: panelWidth)
    }

    private var cellMinHeight: CGFloat {
        BoardLayoutMetrics.discardGemCellMinHeight(gemSize: gemSize)
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

            DiscardGroupedGemGridView(
                gemCounts: gemCounts,
                gemSize: gemSize,
                cellMinHeight: cellMinHeight,
                columnCount: max(gridColumnCount, 1),
                allowsScrolling: allowsScrolling,
                emptyMessage: "No discarded gems"
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
        HStack(spacing: 4) {
            Text(headerTitle)
                .font(.system(size: 10, weight: .heavy, design: .rounded))
                .foregroundStyle(
                    isActiveDestination ? BoardStyle.d12GradientTop : HUDFantasyText.labelColor
                )
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .hudReadableShadow()

            Spacer(minLength: 2)

            if let onDismiss {
                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(BoardStyle.hudValue.opacity(0.9))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Close discard tray")
            }
        }
        .padding(.horizontal, 8)
        .frame(height: BoardLayoutMetrics.discardTrayHeaderLogicalHeight, alignment: .center)
    }
}

#Preview("Discard tray empty") {
    DiscardPileContentsOverlay(
        gemCounts: [],
        discardCount: 0,
        isActiveDestination: false,
        panelWidth: 148,
        panelHeight: 42,
        onDismiss: {}
    )
}

#Preview("Discard tray all kinds") {
    DiscardPileContentsOverlay(
        gemCounts: GemCountDisplayBuilder.displayOrder.map {
            GemCountDisplayItem(kind: $0, count: 2)
        },
        discardCount: GemCountDisplayBuilder.displayOrder.count * 2,
        isActiveDestination: false,
        panelWidth: 280,
        panelHeight: 80,
        gridColumnCount: 6,
        allowsScrolling: false,
        onDismiss: {}
    )
}
