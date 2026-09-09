//
// HandTrayOverlayView.swift
// LepreCON
//
// Bottom gameplay overlay for viewing and placing hand gems.
//

import SwiftUI

struct HandTrayOverlayView: View {
    let gemCounts: [GemCountDisplayItem]
    let canPlace: Bool
    var isKindSelectable: (GemKind) -> Bool = { _ in true }
    let trayHeight: CGFloat
    var onTapKind: (GemKind) -> Void = { _ in }
    var onDismiss: () -> Void = {}

    var body: some View {
        VStack(spacing: 0) {
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture(perform: onDismiss)

            trayPanel
                .frame(height: trayHeight)
        }
        .ignoresSafeArea(edges: .bottom)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Hand gems tray")
    }

    private var trayPanel: some View {
        VStack(spacing: 0) {
            trayHeader

            HandTrayGemGridView(
                gemCounts: gemCounts,
                canPlace: canPlace,
                isKindSelectable: isKindSelectable,
                onTapKind: onTapKind
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(GemTrayPanelChrome.background)
        .overlay(alignment: .top) {
            UnevenRoundedRectangle(
                topLeadingRadius: GemTrayPanelChrome.cornerRadius,
                topTrailingRadius: GemTrayPanelChrome.cornerRadius
            )
            .stroke(BoardStyle.boardGoldOutline.opacity(0.55), lineWidth: 1.25)
            .padding(1)
        }
        .clipShape(
            UnevenRoundedRectangle(
                topLeadingRadius: GemTrayPanelChrome.cornerRadius,
                topTrailingRadius: GemTrayPanelChrome.cornerRadius
            )
        )
        .shadow(color: .black.opacity(0.45), radius: 14, x: 0, y: -4)
    }

    private var trayHeader: some View {
        HStack(spacing: 8) {
            Text("CURRENT GEMS")
                .font(.system(size: 13, weight: .heavy, design: .rounded))
                .foregroundStyle(HUDFantasyText.labelColor)
                .hudReadableShadow()

            Spacer(minLength: 0)

            Button(action: onDismiss) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(BoardStyle.hudValue.opacity(0.92))
                    .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Close hand tray")
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }
}
