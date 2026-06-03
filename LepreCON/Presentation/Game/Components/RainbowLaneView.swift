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
    var innerPadding: CGFloat = 4
    var isHighlighted: Bool = false
    var hasUnicorn: Bool = false

    private var laneCornerRadius: CGFloat { width * 0.42 }
    private var unicornReservedTop: CGFloat { hasUnicorn ? 16 : 0 }

    var body: some View {
        VStack(spacing: 4) {
            ZStack(alignment: .topTrailing) {
                laneBody

                if hasUnicorn {
                    UnicornIndicatorView()
                        .padding(4)
                        .zIndex(1)
                }
            }
            .frame(width: width, height: height)

            Text(laneColor.displayName)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.primary.opacity(0.9))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
    }

    private var laneBody: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: laneCornerRadius, style: .continuous)
                .fill(laneFillColor)
                .overlay(
                    RoundedRectangle(cornerRadius: laneCornerRadius, style: .continuous)
                        .stroke(Color.white.opacity(0.55), lineWidth: 1.5)
                )
                .shadow(color: .black.opacity(0.15), radius: 3, x: 0, y: 2)
                .overlay(highlightBorder)

            GemCountListView(
                items: gemCounts,
                style: .largeLane(laneWidth: width),
                showsShortLabel: false
            )
            .frame(
                width: max(0, width - innerPadding * 2),
                height: max(0, height - innerPadding - unicornReservedTop - 4),
                alignment: .bottomLeading
            )
            .padding(.leading, innerPadding)
            .padding(.trailing, innerPadding)
            .padding(.bottom, innerPadding)
            .padding(.top, unicornReservedTop + 2)
        }
        .frame(width: width, height: height)
        .clipShape(RoundedRectangle(cornerRadius: laneCornerRadius, style: .continuous))
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
            RoundedRectangle(cornerRadius: laneCornerRadius, style: .continuous)
                .stroke(Color.yellow, lineWidth: 2.5)
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
