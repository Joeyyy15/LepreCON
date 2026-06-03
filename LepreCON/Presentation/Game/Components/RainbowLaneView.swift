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
    let gemCounts: [GemCountDisplayItem]
    let width: CGFloat
    let height: CGFloat
    var isHighlighted: Bool = false
    var hasUnicorn: Bool = false

    var body: some View {
        VStack(spacing: 6) {
            ZStack(alignment: .bottomLeading) {
                RoundedRectangle(cornerRadius: width * 0.45)
                    .fill(laneFillColor)
                    .frame(width: width, height: height)
                    .overlay(
                        RoundedRectangle(cornerRadius: width * 0.45)
                            .stroke(.white.opacity(0.55), lineWidth: 2)
                    )
                    .shadow(color: .black.opacity(0.18), radius: 4, x: 0, y: 3)
                    .overlay(highlightBorder)

                GemCountListView(items: gemCounts, style: .largeLane(laneWidth: width))
                    .padding(.horizontal, 3)
                    .padding(.bottom, 5)
            }
            .overlay(alignment: .topTrailing) {
                if hasUnicorn {
                    UnicornIndicatorView()
                        .padding(3)
                }
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

    @ViewBuilder
    private var highlightBorder: some View {
        if isHighlighted {
            RoundedRectangle(cornerRadius: width * 0.45, style: .continuous)
                .stroke(Color.yellow, lineWidth: 3)
        }
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
            width: 42,
            height: 180
        )

        RainbowLaneView(
            laneColor: .orange,
            gemCounts: [GemCountDisplayItem(kind: .orange, count: 2)],
            width: 42,
            height: 180
        )

        RainbowLaneView(
            laneColor: .yellow,
            gemCounts: [GemCountDisplayItem(kind: .yellow, count: 1)],
            width: 42,
            height: 180
        )

        RainbowLaneView(
            laneColor: .green,
            gemCounts: [GemCountDisplayItem(kind: .green, count: 4)],
            width: 42,
            height: 180
        )

        RainbowLaneView(
            laneColor: .blue,
            gemCounts: [GemCountDisplayItem(kind: .blue, count: 2)],
            width: 42,
            height: 180
        )

        RainbowLaneView(
            laneColor: .purple,
            gemCounts: [GemCountDisplayItem(kind: .purple, count: 3)],
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
