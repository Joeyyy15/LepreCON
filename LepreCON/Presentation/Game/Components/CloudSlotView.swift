//
//  CloudSlotView.swift
//  LepreCON
//
//  Visual container for a cloud that can hold gems.
//

import SwiftUI

struct CloudSlotView: View {
    let cloudNumber: Int
    let gemImageNames: [String]
    let width: CGFloat
    let height: CGFloat
    var isHighlighted: Bool = false
    var hasUnicorn: Bool = false

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                cloudShape

                if gemImageNames.isEmpty {
                    Text("Cloud \(cloudNumber)")
                        .font(.caption2)
                        .bold()
                        .foregroundStyle(.black.opacity(0.45))
                } else {
                    gemPile
                }

                if hasUnicorn {
                    UnicornIndicatorView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                        .padding(4)
                }
            }
            .frame(width: width, height: height)
            .overlay(highlightBorder)

            Text("Cloud \(cloudNumber)")
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

    private var gemPile: some View {
        ZStack {
            ForEach(Array(gemImageNames.prefix(5).enumerated()), id: \.offset) { index, imageName in
                GemView(imageName: imageName, size: height * 0.34)
                    .offset(
                        x: CGFloat(index - 2) * width * 0.10,
                        y: CGFloat(index % 2) * height * 0.08
                    )
            }
        }
        .offset(y: height * 0.05)
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
                gemImageNames: ["gem_red", "gem_blue"],
                width: 120,
                height: 80
            )

            CloudSlotView(
                cloudNumber: 2,
                gemImageNames: [],
                width: 120,
                height: 80
            )
        }

        HStack(spacing: 18) {
            CloudSlotView(
                cloudNumber: 3,
                gemImageNames: ["gem_green", "gem_yellow", "gem_purple"],
                width: 120,
                height: 80
            )

            CloudSlotView(
                cloudNumber: 4,
                gemImageNames: ["gem_black", "gem_white"],
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
