//
//  CloudSlotView.swift
//  LepreCON
//
//  Visual container for a cloud cup on the board.
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
        ZStack(alignment: .topTrailing) {
            ZStack {
                cloudCupWell
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
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Cloud cup \(cloudNumber)")
        .accessibilityAddTraits(isHighlighted ? .isSelected : [])
    }

    private var cloudCupWell: some View {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.55),
                        Color(red: 0.85, green: 0.9, blue: 0.95).opacity(0.35)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.black.opacity(0.12), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
    }

    @ViewBuilder
    private var cupContent: some View {
        if gemCounts.isEmpty {
            Color.clear
        } else {
            BoardCupGemCluster(
                items: gemCounts,
                width: max(0, width - innerPadding * 2),
                height: max(0, height - innerPadding * 2 - unicornReservedTop),
                showsKindLabel: true
            )
            .padding(.horizontal, innerPadding)
            .padding(.top, unicornReservedTop + innerPadding * 0.5)
            .padding(.bottom, innerPadding)
        }
    }

    private var cloudShape: some View {
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
        .shadow(color: .black.opacity(0.12), radius: 3, x: 0, y: 2)
        .overlay(
            Capsule()
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                .frame(width: width * 0.88, height: height * 0.45)
                .offset(y: height * 0.12)
        )
    }

    @ViewBuilder
    private var highlightBorder: some View {
        if isHighlighted {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.yellow, lineWidth: 2.5)
                .padding(1)
        }
    }
}
