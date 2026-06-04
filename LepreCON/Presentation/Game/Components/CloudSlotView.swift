//
//  CloudSlotView.swift
//  LepreCON
//
//  Visual container for a cloud cup on the board.
//

import SwiftUI
import UIKit

struct CloudSlotView: View {
    let cloudNumber: Int
    let gemCounts: [GemCountDisplayItem]
    let width: CGFloat
    let height: CGFloat
    var innerPadding: CGFloat = 5
    var isHighlighted: Bool = false
    var hasUnicorn: Bool = false

    private static let cloudAssetName = "cloud_cup"

    /// Scales cloud artwork to fill most of the slot without changing layout metrics.
    private var cloudArtScale: CGFloat { 1.26 }

    private var unicornReservedTop: CGFloat { hasUnicorn ? 14 : 0 }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            ZStack(alignment: .top) {
                cloudShape
                cupContent
            }
            .frame(width: width, height: height, alignment: .top)

            if hasUnicorn {
                UnicornIndicatorView()
                    .padding(3)
                    .zIndex(1)
            }
        }
        .frame(width: width, height: height)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Cloud cup \(cloudNumber)")
        .accessibilityAddTraits(isHighlighted ? .isSelected : [])
    }

    @ViewBuilder
    private var cupContent: some View {
        if gemCounts.isEmpty {
            Color.clear
        } else {
            BoardCupGemCluster(
                items: gemCounts,
                width: max(0, width - innerPadding * 2),
                height: max(0, height * 0.42 - unicornReservedTop),
                showsKindLabel: true
            )
            .padding(.horizontal, innerPadding)
            .padding(.top, unicornReservedTop + innerPadding * 0.25)
            .offset(y: height * 0.04)
            .zIndex(2)
        }
    }

    @ViewBuilder
    private var cloudShape: some View {
        let artwork = Group {
            if UIImage(named: Self.cloudAssetName) != nil {
                Image(Self.cloudAssetName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: width, height: height, alignment: .top)
                    .scaleEffect(cloudArtScale, anchor: .top)
            } else {
                proceduralCloudShape
            }
        }

        artwork
            .shadow(color: .black.opacity(0.14), radius: 4, x: 0, y: 2)
            .shadow(color: isHighlighted ? Color.yellow.opacity(0.9) : .clear, radius: 12)
            .shadow(color: isHighlighted ? Color.orange.opacity(0.55) : .clear, radius: 5)
            .overlay {
                if isHighlighted, UIImage(named: Self.cloudAssetName) != nil {
                    Image(Self.cloudAssetName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: width, height: height, alignment: .top)
                        .scaleEffect(cloudArtScale, anchor: .top)
                        .allowsHitTesting(false)
                        .opacity(0.35)
                        .blendMode(.screen)
                }
            }
    }

    private var proceduralCloudShape: some View {
        ZStack {
            Capsule()
                .fill(.white.opacity(0.95))
                .frame(width: width * 0.88, height: height * 0.45)
                .offset(y: height * 0.12)

            Circle()
                .fill(.white.opacity(0.95))
                .frame(width: height * 0.55, height: height * 0.55)
                .offset(x: -width * 0.22, y: -height * 0.02)

            Circle()
                .fill(.white.opacity(0.98))
                .frame(width: height * 0.72, height: height * 0.72)
                .offset(x: 0, y: -height * 0.12)

            Circle()
                .fill(.white.opacity(0.95))
                .frame(width: height * 0.55, height: height * 0.55)
                .offset(x: width * 0.24, y: -height * 0.02)
        }
        .frame(width: width, height: height, alignment: .top)
        .scaleEffect(cloudArtScale, anchor: .top)
    }
}
