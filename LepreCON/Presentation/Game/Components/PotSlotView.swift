//
//  PotSlotView.swift
//  LepreCON
//
//  Temporary visual container for the pot of gold.
//  Later, this can be replaced with a polished PNG asset.
//

import SwiftUI

struct PotSlotView: View {
    let gemImageNames: [String]
    let width: CGFloat
    let height: CGFloat

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                potShape

                if gemImageNames.isEmpty {
                    Text("Pot")
                        .font(.caption)
                        .bold()
                        .foregroundStyle(.white.opacity(0.75))
                        .offset(y: height * 0.08)
                } else {
                    gemPile
                }
            }
            .frame(width: width, height: height)

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

    private var gemPile: some View {
        ZStack {
            ForEach(Array(gemImageNames.prefix(6).enumerated()), id: \.offset) { index, imageName in
                GemView(imageName: imageName, size: height * 0.24)
                    .offset(
                        x: CGFloat(index - 2) * width * 0.08,
                        y: CGFloat(index % 3) * height * 0.07 - height * 0.10
                    )
            }
        }
    }
}

#Preview("Pot Slot") {
    HStack(spacing: 32) {
        PotSlotView(
            gemImageNames: [],
            width: 130,
            height: 110
        )

        PotSlotView(
            gemImageNames: [
                "gem_red",
                "gem_blue",
                "gem_green",
                "gem_yellow",
                "gem_purple"
            ],
            width: 130,
            height: 110
        )
    }
    .padding(32)
    .background(.green.opacity(0.18))
}
