//
//  PotSlotView.swift
//  LepreCON
//
//  Temporary visual container for the pot of gold.
//  Later, this can be replaced with a polished PNG asset.
//

import SwiftUI

struct PotSlotView: View {
    let gemCounts: [GemCountDisplayItem]
    let width: CGFloat
    let height: CGFloat
    var isHighlighted: Bool = false

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                potShape

                if gemCounts.isEmpty {
                    Text("Pot")
                        .font(.caption)
                        .bold()
                        .foregroundStyle(.white.opacity(0.75))
                        .offset(y: height * 0.08)
                } else {
                    GemCountListView(items: gemCounts, gemSize: height * 0.22)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        .padding(.horizontal, 4)
                        .offset(y: -height * 0.06)
                }
            }
            .frame(width: width, height: height)
            .overlay(highlightBorder)

            Text("Pot")
                .font(.caption2)
                .bold()
        }
    }

    private var potShape: some View {
        ZStack {
            // Pot body.
            RoundedRectangle(cornerRadius: width * 0.18)
                .fill(
                    LinearGradient(
                        colors: [
                            .black.opacity(0.9),
                            .gray.opacity(0.8),
                            .black.opacity(0.95)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: width * 0.82, height: height * 0.58)
                .offset(y: height * 0.13)

            // Pot rim.
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [
                            .gray.opacity(0.9),
                            .black.opacity(0.9)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: width * 0.92, height: height * 0.28)
                .offset(y: -height * 0.08)

            // Gold glow inside the pot.
            Capsule()
                .fill(.yellow.opacity(0.55))
                .frame(width: width * 0.68, height: height * 0.14)
                .offset(y: -height * 0.11)

            // Pot border.
            RoundedRectangle(cornerRadius: width * 0.18)
                .stroke(.white.opacity(0.18), lineWidth: 2)
                .frame(width: width * 0.82, height: height * 0.58)
                .offset(y: height * 0.13)
        }
        .shadow(color: .black.opacity(0.25), radius: 6, x: 0, y: 4)
    }

    @ViewBuilder
    private var highlightBorder: some View {
        if isHighlighted {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.yellow, lineWidth: 3)
                .padding(2)
        }
    }
}

#Preview("Pot Slot") {
    HStack(spacing: 32) {
        PotSlotView(
            gemCounts: [],
            width: 130,
            height: 110
        )

        PotSlotView(
            gemCounts: [
                GemCountDisplayItem(kind: .gold, count: 3),
                GemCountDisplayItem(kind: .red, count: 1)
            ],
            width: 130,
            height: 110
        )
    }
    .padding(32)
    .background(.green.opacity(0.18))
}
