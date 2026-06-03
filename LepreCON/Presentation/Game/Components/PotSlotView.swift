//
//  PotSlotView.swift
//  LepreCON
//
//  Visual container for the pot of gold on the board.
//

import SwiftUI

struct PotSlotView: View {
    let gemCounts: [GemCountDisplayItem]
    let width: CGFloat
    let height: CGFloat
    var innerPadding: CGFloat = 5
    var isHighlighted: Bool = false

    var body: some View {
        ZStack {
            potPedestal
            potShape
            potContent
        }
        .frame(width: width, height: height)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(BoardStyle.boardGoldOutline.opacity(0.85), lineWidth: 1.25)
        )
        .overlay(highlightBorder)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Pot of Gold")
        .accessibilityAddTraits(isHighlighted ? .isSelected : [])
    }

    private var potPedestal: some View {
        RoundedRectangle(cornerRadius: 14, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        Color(red: 0.15, green: 0.12, blue: 0.08).opacity(0.5),
                        Color.black.opacity(0.25)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
    }

    @ViewBuilder
    private var potContent: some View {
        if gemCounts.isEmpty {
            Color.clear
        } else {
            BoardCupGemCluster(
                items: gemCounts,
                width: max(0, width - innerPadding * 2),
                height: max(0, height * 0.68),
                showsKindLabel: true
            )
            .padding(.horizontal, innerPadding)
            .offset(y: -height * 0.08)
        }
    }

    private var potShape: some View {
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
        .shadow(color: Color.yellow.opacity(0.15), radius: 6, x: 0, y: 0)
        .shadow(color: .black.opacity(0.3), radius: 6, x: 0, y: 4)
    }

    @ViewBuilder
    private var highlightBorder: some View {
        if isHighlighted {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.yellow, lineWidth: 2.5)
                .padding(1)
        }
    }
}
