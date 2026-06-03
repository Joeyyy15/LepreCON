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
    var isHighlighted: Bool = false
    var hasUnicorn: Bool = false

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                cloudShape

                if gemCounts.isEmpty {
                    Text("C\(cloudNumber)")
                        .font(.caption2)
                        .bold()
                        .foregroundStyle(.black.opacity(0.45))
                } else {
                    GemCountListView(items: gemCounts, style: .compact(gemSize: height * 0.28))
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        .padding(.horizontal, 4)
                        .padding(.top, hasUnicorn ? 14 : 0)
                }
            }
            .frame(width: width, height: height)
            .overlay(alignment: .topTrailing) {
                if hasUnicorn {
                    UnicornIndicatorView()
                        .padding(2)
                }
            }
            .overlay(highlightBorder)

            Text("C\(cloudNumber)")
                .font(.caption2)
                .bold()
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
