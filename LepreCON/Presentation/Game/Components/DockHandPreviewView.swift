//
// DockHandPreviewView.swift
// LepreCON
//
// Compact tappable hand summary for the bottom dock right panel.
//

import SwiftUI

struct DockHandPreviewView: View {
    let gemCounts: [GemCountDisplayItem]
    let canOpenTray: Bool
    var onOpenTray: () -> Void = {}

    private var totalGemCount: Int {
        gemCounts.reduce(0) { $0 + $1.count }
    }

    private var countLabel: String {
        switch totalGemCount {
        case 0:
            return "No gems"
        case 1:
            return "1 gem"
        default:
            return "\(totalGemCount) gems"
        }
    }

    private var previewItems: [GemCountDisplayItem] {
        Array(gemCounts.prefix(GameScreenLayout.handTrayDockPreviewMaxGems))
    }

    var body: some View {
        Button(action: onOpenTray) {
            VStack(spacing: 3) {
                Text(countLabel)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(HUDFantasyText.valueColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                    .hudReadableShadow()

                if !previewItems.isEmpty {
                    HStack(spacing: 4) {
                        ForEach(previewItems) { item in
                            GemView(
                                imageName: item.imageName,
                                size: GameScreenLayout.handTrayPreviewGemSize
                            )
                            .opacity(canOpenTray ? 1 : 0.55)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(!canOpenTray)
        .accessibilityLabel(handAccessibilityLabel)
        .accessibilityHint("Opens your hand gems")
        .accessibilityAddTraits(.isButton)
    }

    private var handAccessibilityLabel: String {
        "Hand, \(countLabel)"
    }
}
