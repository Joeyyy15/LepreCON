//
// DiscardPileContentsOverlay.swift
// LepreCON
//
// Wide read-only discard contents panel. Drawn as an overlay so it never
// resizes the board, Pot, clouds, or rainbow lanes.
//

import SwiftUI

/// Hand-matching discard contents overlay. Viewing only — no domain mutations.
struct DiscardPileContentsOverlay: View {
    let gemCounts: [GemCountDisplayItem]
    let isActiveDestination: Bool
    let panelWidth: CGFloat
    let panelHeight: CGFloat
    var onDismiss: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 0) {
            header

            HandTrayGemGridView(
                gemCounts: gemCounts,
                canPlace: false,
                showsDisabledAppearance: false,
                emptyMessage: "Discard pile empty",
                gemSize: max(36, min(52, panelWidth * 0.12)),
                cellMinHeight: max(64, min(78, panelHeight * 0.42))
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(width: panelWidth, height: panelHeight)
        .background(GemTrayPanelChrome.background)
        .overlay {
            GemTrayPanelChrome.borderStroke(isEmphasized: isActiveDestination)
                .padding(1)
        }
        .clipShape(RoundedRectangle(cornerRadius: GemTrayPanelChrome.cornerRadius, style: .continuous))
        .shadow(color: .black.opacity(0.45), radius: 14, x: 0, y: 4)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Discard pile contents")
    }

    private var header: some View {
        HStack(spacing: 8) {
            Text(isActiveDestination ? "DISCARD 1 GEM" : "DISCARD")
                .font(.system(size: 13, weight: .heavy, design: .rounded))
                .foregroundStyle(
                    isActiveDestination ? BoardStyle.d12GradientTop : HUDFantasyText.labelColor
                )
                .lineLimit(1)
                .minimumScaleFactor(0.85)
                .hudReadableShadow()

            Spacer(minLength: 8)

            if let onDismiss {
                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(BoardStyle.hudValue.opacity(0.92))
                        .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Close discard pile")
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }
}
