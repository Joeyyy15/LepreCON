//
//  RainbowLaneView.swift
//  LepreCON
//
//  Visual container for one colored rainbow lane (gem chute).
//

import SwiftUI
import UIKit

// MARK: - Lane background only (sits behind cloud/pot in board ZStack)

struct RainbowLaneBackgroundView: View {
    let laneColor: RainbowLaneColor
    let width: CGFloat
    let height: CGFloat
    var isHighlighted: Bool = false

    private var laneTopCornerRadius: CGFloat { width * 0.42 }
    private var laneBottomCornerRadius: CGFloat { width * 0.14 }
    private var laneShape: UnevenRoundedRectangle {
        UnevenRoundedRectangle(
            topLeadingRadius: laneTopCornerRadius,
            bottomLeadingRadius: laneBottomCornerRadius,
            bottomTrailingRadius: laneBottomCornerRadius,
            topTrailingRadius: laneTopCornerRadius
        )
    }

    var body: some View {
        Group {
            if UIImage(named: laneColor.laneBackgroundAssetName) != nil {
                laneArtwork
            } else {
                proceduralLaneBackground
            }
        }
        .frame(width: width, height: height)
        .accessibilityHidden(true)
    }

    @ViewBuilder
    private var laneArtwork: some View {
        Image(laneColor.laneBackgroundAssetName)
            .resizable()
            .scaledToFill()
            .frame(width: width, height: height, alignment: .top)
            .clipped()
            .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 3)
            .shadow(color: isHighlighted ? Color.yellow.opacity(0.9) : .clear, radius: 12)
            .shadow(color: isHighlighted ? Color.orange.opacity(0.55) : .clear, radius: 5)
            .overlay {
                if isHighlighted {
                    Image(laneColor.laneBackgroundAssetName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: width, height: height, alignment: .top)
                        .clipped()
                        .allowsHitTesting(false)
                        .opacity(0.35)
                        .blendMode(.screen)
                }
            }
    }

    private var proceduralLaneBackground: some View {
        laneShape
            .fill(
                LinearGradient(
                    colors: [laneFillColor.opacity(0.92), laneDeepColor],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .overlay(laneGlassShine)
            .overlay(
                laneShape
                    .stroke(laneFillColor.opacity(0.55), lineWidth: 1)
                    .padding(2)
            )
            .overlay(
                laneShape
                    .stroke(Color.black.opacity(0.4), lineWidth: 1.5)
            )
            .shadow(color: laneDeepColor.opacity(0.8), radius: 2, x: 0, y: 2)
            .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 3)
            .overlay(highlightBorder)
    }

    private var laneGlassShine: some View {
        LinearGradient(
            colors: [
                Color.white.opacity(0.22),
                Color.white.opacity(0.06),
                Color.clear
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .clipShape(laneShape)
    }

    private var laneFillColor: Color {
        switch laneColor {
        case .red: return .red
        case .orange: return .orange
        case .yellow: return .yellow
        case .green: return .green
        case .blue: return .blue
        case .purple: return .purple
        }
    }

    private var laneDeepColor: Color {
        switch laneColor {
        case .red: return Color(red: 0.45, green: 0.05, blue: 0.08)
        case .orange: return Color(red: 0.55, green: 0.22, blue: 0.02)
        case .yellow: return Color(red: 0.45, green: 0.38, blue: 0.05)
        case .green: return Color(red: 0.05, green: 0.38, blue: 0.12)
        case .blue: return Color(red: 0.05, green: 0.18, blue: 0.45)
        case .purple: return Color(red: 0.28, green: 0.05, blue: 0.42)
        }
    }

    @ViewBuilder
    private var highlightBorder: some View {
        if isHighlighted {
            laneShape
                .stroke(Color.yellow, lineWidth: 2.5)
        }
    }
}

// MARK: - Combined lane (preview / legacy)

struct RainbowLaneView: View {
    let laneColor: RainbowLaneColor
    let gemCounts: [GemCountDisplayItem]
    let width: CGFloat
    let height: CGFloat
    var innerPadding: CGFloat = 4
    var isHighlighted: Bool = false
    var hasUnicorn: Bool = false

    private var unicornReservedTop: CGFloat { hasUnicorn ? 16 : 0 }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            ZStack(alignment: .bottom) {
                RainbowLaneBackgroundView(
                    laneColor: laneColor,
                    width: width,
                    height: height,
                    isHighlighted: isHighlighted
                )

                BoardLaneGemStack(
                    items: gemCounts,
                    width: max(0, width - innerPadding * 2),
                    height: max(0, height - innerPadding - unicornReservedTop - 4)
                )
                .padding(.horizontal, innerPadding)
                .padding(.bottom, innerPadding)
                .padding(.top, unicornReservedTop + 2)
            }

            if hasUnicorn {
                UnicornIndicatorView()
                    .padding(4)
                    .zIndex(1)
            }
        }
        .frame(width: width, height: height)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(laneColor.displayName) lane")
        .accessibilityAddTraits(isHighlighted ? .isSelected : [])
    }
}

#Preview("Rainbow Lanes") {
    HStack(alignment: .bottom, spacing: 10) {
        RainbowLaneView(
            laneColor: .red,
            gemCounts: [
                GemCountDisplayItem(kind: .red, count: 3),
                GemCountDisplayItem(kind: .gold, count: 1)
            ],
            width: 54,
            height: 200
        )

        RainbowLaneView(
            laneColor: .orange,
            gemCounts: [],
            width: 54,
            height: 200
        )
    }
    .padding(32)
    .background(BoardContainerView { Color.clear.frame(height: 200) })
}
