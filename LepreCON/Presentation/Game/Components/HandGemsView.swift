//
// HandGemsView.swift
// LepreCON
//
// Wrapping grid of hand gems so a normal D12 draw is visible without horizontal scrolling.
//

import SwiftUI

struct HandGemsView: View {
    let gems: [GemDisplayItem]
    var canPlace: Bool = false
    var isInteractive: Bool = true
    var onTapGem: (UUID) -> Void = { _ in }

    private let columns = [
        GridItem(.adaptive(minimum: 56, maximum: 80), spacing: 10)
    ]

    var body: some View {
        LazyVGrid(columns: columns, alignment: .leading, spacing: 10) {
            ForEach(gems) { gem in
                if isInteractive {
                    Button {
                        onTapGem(gem.id)
                    } label: {
                        HandGemTileView(gem: gem, size: 52)
                    }
                    .buttonStyle(.plain)
                    .disabled(!canPlace)
                } else {
                    HandGemTileView(gem: gem, size: 36)
                }
            }
        }
    }
}

/// One tappable hand gem with an optional label when PNGs look alike (gold/yellow, clear/white, etc.).
struct HandGemTileView: View {
    let gem: GemDisplayItem
    let size: CGFloat

    var body: some View {
        ZStack(alignment: .bottom) {
            GemView(imageName: gem.imageName, size: size)
                .padding(8)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.white.opacity(0.12))
                )

            if let overlay = gem.kind.handGemOverlayLabel {
                Text(overlay)
                    .font(.system(size: 9, weight: .heavy))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(Color.black.opacity(0.72))
                    )
                    .padding(.bottom, 4)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(gem.kind.gemCountDisplayName)
    }
}

#Preview("Hand Gems") {
    HandGemsView(
        gems: [
            GemDisplayItem(id: UUID(), imageName: "gem_yellow", kind: .gold),
            GemDisplayItem(id: UUID(), imageName: "gem_white", kind: .clear),
            GemDisplayItem(id: UUID(), imageName: "gem_white", kind: .white),
            GemDisplayItem(id: UUID(), imageName: "gem_purple", kind: .pink),
            GemDisplayItem(id: UUID(), imageName: "gem_black", kind: .black)
        ],
        canPlace: true,
        onTapGem: { _ in }
    )
    .padding()
}
