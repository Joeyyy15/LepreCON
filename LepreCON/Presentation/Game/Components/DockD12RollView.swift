//
// DockD12RollView.swift
// LepreCON
//
// Center of the control dock: tap to roll D12.
//

import SwiftUI

struct DockD12RollView: View {
    let showsRollControl: Bool
    let canRollD12: Bool
    let currentRoll: Int?
    var compactOnArtBackground: Bool = false
    var onRollD12: () -> Void = {}

    private var tileSize: CGFloat {
        compactOnArtBackground ? HUDBarArtLayout.dockRollDieSize : 86
    }

    var body: some View {
        Group {
            if showsRollControl {
                if compactOnArtBackground {
                    dieButton
                } else {
                    VStack(spacing: 5) {
                        dieButton
                        Text("ROLL D12")
                            .font(HUDFantasyText.rollCaptionFont)
                            .foregroundStyle(BoardStyle.hudValue)
                            .hudReadableShadow()
                    }
                    .accessibilityLabel("Roll D12")
                }
            }
        }
    }

    private var dieButton: some View {
        Button(action: onRollD12) {
            d12Tile
        }
        .buttonStyle(.plain)
        .disabled(!canRollD12)
        .opacity(canRollD12 ? 1 : 0.5)
        .scaleEffect(canRollD12 ? 1 : 0.94)
        .accessibilityLabel("Roll D12")
    }

    private var d12Tile: some View {
        ZStack {
            RoundedRectangle(cornerRadius: compactOnArtBackground ? 14 : 16, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            BoardStyle.d12GradientTop,
                            BoardStyle.d12GradientBottom
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: tileSize, height: tileSize)
                .overlay(
                    RoundedRectangle(cornerRadius: compactOnArtBackground ? 14 : 16, style: .continuous)
                        .stroke(Color(red: 0.62, green: 0.42, blue: 0.06), lineWidth: 2.5)
                )
                .shadow(
                    color: Color(red: 1.0, green: 0.85, blue: 0.3).opacity(canRollD12 ? 0.45 : 0.1),
                    radius: 6,
                    x: 0,
                    y: 0
                )
                .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)

            Text(rollFaceText)
                .font(.system(size: compactOnArtBackground ? 28 : 32, weight: .black, design: .rounded))
                .foregroundStyle(Color(red: 0.32, green: 0.18, blue: 0.04))
                .minimumScaleFactor(0.5)
        }
    }

    private var rollFaceText: String {
        if let currentRoll {
            return "\(currentRoll)"
        }
        return "D12"
    }
}
