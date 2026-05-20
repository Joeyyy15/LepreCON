//
//  RainbowLaneView.swift
//  LepreCON
//
//  Visual container for one colored rainbow lane.
//  Each lane stacks gems upward like a bar chart.
//  prototype switching to better graphics later

import SwiftUI

struct RainbowLaneView: View {
    let laneColor: RainbowLaneColor
    let gemImageNames: [String]
    let width: CGFloat
    let height: CGFloat

    var body: some View {
        VStack(spacing: 6) {
            ZStack(alignment: .bottom) {
                // The colored rainbow lane background.
                RoundedRectangle(cornerRadius: width * 0.45)
                    .fill(laneFillColor)
                    .frame(width: width, height: height)
                    .overlay(
                        RoundedRectangle(cornerRadius: width * 0.45)
                            .stroke(.white.opacity(0.55), lineWidth: 2)
                    )
                    .shadow(color: .black.opacity(0.18), radius: 4, x: 0, y: 3)

                // Gems stack upward from the bottom of the lane.
                VStack(spacing: -4) {
                    ForEach(Array(gemImageNames.enumerated()), id: \.offset) { _, imageName in
                        GemView(imageName: imageName, size: width * 0.85)
                    }
                }
                .padding(.bottom, 6)
            }

            Text(laneColor.displayName)
                .font(.caption2)
                .bold()
        }
    }

    private var laneFillColor: Color {
        switch laneColor {
        case .red:
            return .red
        case .orange:
            return .orange
        case .yellow:
            return .yellow
        case .green:
            return .green
        case .blue:
            return .blue
        case .purple:
            return .purple
        }
    }
}

#Preview("Rainbow Lanes") {
    HStack(alignment: .bottom, spacing: 10) {
        RainbowLaneView(
            laneColor: .red,
            gemImageNames: ["gem_red", "gem_red", "gem_red"],
            width: 42,
            height: 180
        )

        RainbowLaneView(
            laneColor: .orange,
            gemImageNames: ["gem_orange", "gem_orange"],
            width: 42,
            height: 180
        )

        RainbowLaneView(
            laneColor: .yellow,
            gemImageNames: ["gem_yellow"],
            width: 42,
            height: 180
        )

        RainbowLaneView(
            laneColor: .green,
            gemImageNames: ["gem_green", "gem_green", "gem_green", "gem_green"],
            width: 42,
            height: 180
        )

        RainbowLaneView(
            laneColor: .blue,
            gemImageNames: ["gem_blue", "gem_blue"],
            width: 42,
            height: 180
        )

        RainbowLaneView(
            laneColor: .purple,
            gemImageNames: ["gem_purple", "gem_purple", "gem_purple"],
            width: 42,
            height: 180
        )
    }
    .padding(32)
    .background(
        LinearGradient(
            colors: [.cyan.opacity(0.25), .green.opacity(0.18)],
            startPoint: .top,
            endPoint: .bottom
        )
    )
}
