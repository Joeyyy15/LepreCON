//
//  CloudSlotView.swift
//  LepreCON
//
//  Visual container for a cloud that can hold gems.
//

import SwiftUI

struct CloudSlotView: View {
    let cloudNumber: Int
    let gemCounts: [GemCountDisplayItem]
    let width: CGFloat
    let height: CGFloat
    var innerPadding: CGFloat = 5
    var isHighlighted: Bool = false
    var hasUnicorn: Bool = false

    private var unicornReservedTop: CGFloat { hasUnicorn ? 14 : 0 }

    var body: some View {
        VStack(spacing: 4) {
            ZStack(alignment: .topTrailing) {
                ZStack {
                    cloudShape

                    cupContent
                }
                .frame(width: width, height: height)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(highlightBorder)

                if hasUnicorn {
                    UnicornIndicatorView()
                        .padding(3)
                        .zIndex(1)
                }
            }
            .frame(width: width, height: height)

            Text("C\(cloudNumber)")
                .font(.caption2.weight(.semibold))
                .lineLimit(1)
        }
    }

    @ViewBuilder
    private var cupContent: some View {
        if gemCounts.isEmpty {
            Text("C\(cloudNumber)")
                .font(.caption2.weight(.bold))
                .foregroundStyle(.black.opacity(0.4))
        } else {
            GemCountListView(
                items: gemCounts,
                style: .compact(gemSize: min(height * 0.24, 14)),
                showsShortLabel: true
            )
            .frame(
                maxWidth: max(0, width - innerPadding * 2),
                maxHeight: max(0, height - innerPadding * 2 - unicornReservedTop),
                alignment: .center
            )
            .padding(.horizontal, innerPadding)
            .padding(.top, unicornReservedTop + innerPadding * 0.5)
            .padding(.bottom, innerPadding)
        }
    }

    private var cloudShape: some View {
        ZStack {
            Capsule()
                .fill(.white)
                .frame(width: width * 0.88, height: height * 0.45)
                .offset(y: height * 0.12)

            Circle()
                .fill(.white)
                .frame(width: height * 0.55, height: height * 0.55)
                .offset(x: -width * 0.22, y: -height * 0.02)

            Circle()
                .fill(.white)
                .frame(width: height * 0.72, height: height * 0.72)
                .offset(x: 0, y: -height * 0.12)

            Circle()
                .fill(.white)
                .frame(width: height * 0.55, height: height * 0.55)
                .offset(x: width * 0.24, y: -height * 0.02)
        }
        .shadow(color: .black.opacity(0.18), radius: 5, x: 0, y: 3)
        .overlay(
            ZStack {
                Capsule()
                    .stroke(.gray.opacity(0.25), lineWidth: 2)
                    .frame(width: width * 0.88, height: height * 0.45)
                    .offset(y: height * 0.12)
            }
        )
    }

    @ViewBuilder
    private var highlightBorder: some View {
        if isHighlighted {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.yellow, lineWidth: 3)
                .padding(2)
        }
    }
}

#Preview("Cloud Slots") {
    VStack(spacing: 24) {
        HStack(spacing: 18) {
            CloudSlotView(
                cloudNumber: 1,
                gemCounts: [
                    GemCountDisplayItem(kind: .red, count: 1),
                    GemCountDisplayItem(kind: .blue, count: 1)
                ],
                width: 120,
                height: 80
            )

            CloudSlotView(
                cloudNumber: 2,
                gemCounts: [],
                width: 120,
                height: 80
            )
        }

        HStack(spacing: 18) {
            CloudSlotView(
                cloudNumber: 3,
                gemCounts: [
                    GemCountDisplayItem(kind: .green, count: 1),
                    GemCountDisplayItem(kind: .yellow, count: 1)
                ],
                width: 120,
                height: 80
            )

            CloudSlotView(
                cloudNumber: 4,
                gemCounts: [
                    GemCountDisplayItem(kind: .black, count: 1),
                    GemCountDisplayItem(kind: .white, count: 1)
                ],
                width: 120,
                height: 80
            )
        }
    }
    .padding(32)
    .background(
        LinearGradient(
            colors: [.cyan.opacity(0.25), .blue.opacity(0.12)],
            startPoint: .top,
            endPoint: .bottom
        )
    )
}
