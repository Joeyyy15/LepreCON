//
//  PotSlotView.swift
//  LepreCON
//
//  Visual container for the pot of gold on the board.
//

import SwiftUI
import UIKit

struct PotSlotView: View {
    let gemCounts: [GemCountDisplayItem]
    let width: CGFloat
    let height: CGFloat
    var innerPadding: CGFloat = 5
    var isHighlighted: Bool = false

    private static let potAssetName = "pot_of_gold"

    var body: some View {
        ZStack(alignment: .top) {
            potShape
            potContent
        }
        .frame(width: width, height: height, alignment: .top)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Pot of Gold")
        .accessibilityAddTraits(isHighlighted ? .isSelected : [])
    }

    @ViewBuilder
    private var potContent: some View {
        if gemCounts.isEmpty {
            Color.clear
        } else {
            BoardCupGemCluster(
                items: gemCounts,
                width: max(0, width - innerPadding * 2),
                height: max(0, height * 0.78),
                showsKindLabel: true
            )
            .padding(.horizontal, innerPadding)
            .offset(y: -height * 0.08)
            .zIndex(1)
        }
    }

    @ViewBuilder
    private var potShape: some View {
        Group {
            if UIImage(named: Self.potAssetName) != nil {
                Image(Self.potAssetName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: width, height: height, alignment: .top)
            } else {
                proceduralPotShape
            }
        }
        .shadow(color: Color.yellow.opacity(isHighlighted ? 0.45 : 0.15), radius: isHighlighted ? 10 : 6, x: 0, y: 0)
        .shadow(color: .black.opacity(0.3), radius: 6, x: 0, y: 4)
        .shadow(color: isHighlighted ? Color.yellow.opacity(0.85) : .clear, radius: 12)
        .overlay {
            if isHighlighted, UIImage(named: Self.potAssetName) != nil {
                Image(Self.potAssetName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: width, height: height, alignment: .top)
                    .allowsHitTesting(false)
                    .opacity(0.35)
                    .blendMode(.screen)
            }
        }
    }

    private var proceduralPotShape: some View {
        ZStack {
            RoundedRectangle(cornerRadius: width * 0.18)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.15, green: 0.12, blue: 0.1),
                            Color(red: 0.35, green: 0.3, blue: 0.25),
                            Color.black.opacity(0.95)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: width * 0.82, height: height * 0.58)
                .offset(y: height * 0.13)

            Capsule()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.55, green: 0.48, blue: 0.35),
                            Color(red: 0.2, green: 0.16, blue: 0.12)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: width * 0.92, height: height * 0.28)
                .offset(y: -height * 0.08)

            Capsule()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.yellow.opacity(0.75),
                            Color.orange.opacity(0.45)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: width * 0.7, height: height * 0.16)
                .offset(y: -height * 0.1)
                .blur(radius: 0.5)

            RoundedRectangle(cornerRadius: width * 0.18)
                .stroke(Color(red: 0.85, green: 0.68, blue: 0.25).opacity(0.45), lineWidth: 1.5)
                .frame(width: width * 0.82, height: height * 0.58)
                .offset(y: height * 0.13)
        }
        .overlay {
            if isHighlighted {
                RoundedRectangle(cornerRadius: width * 0.18)
                    .stroke(Color.yellow.opacity(0.85), lineWidth: 2.5)
                    .frame(width: width * 0.82, height: height * 0.58)
                    .offset(y: height * 0.13)
                    .allowsHitTesting(false)
            }
        }
    }
}
