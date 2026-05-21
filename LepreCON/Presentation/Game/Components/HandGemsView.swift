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
        GridItem(.adaptive(minimum: 56, maximum: 72), spacing: 10)
    ]

    var body: some View {
        LazyVGrid(columns: columns, alignment: .leading, spacing: 10) {
            ForEach(gems) { gem in
                if isInteractive {
                    Button {
                        onTapGem(gem.id)
                    } label: {
                        gemTile(imageName: gem.imageName)
                    }
                    .buttonStyle(.plain)
                    .disabled(!canPlace)
                } else {
                    gemTile(imageName: gem.imageName, size: 36)
                }
            }
        }
    }

    @ViewBuilder
    private func gemTile(imageName: String, size: CGFloat = 52) -> some View {
        GemView(imageName: imageName, size: size)
            .padding(isInteractive ? 8 : 4)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.white.opacity(0.12))
            )
    }
}

#Preview("Hand Gems") {
    HandGemsView(
        gems: [
            GemDisplayItem(id: UUID(), imageName: "gem_red", kind: .red),
            GemDisplayItem(id: UUID(), imageName: "gem_blue", kind: .blue),
            GemDisplayItem(id: UUID(), imageName: "gem_green", kind: .green),
            GemDisplayItem(id: UUID(), imageName: "gem_yellow", kind: .yellow),
            GemDisplayItem(id: UUID(), imageName: "gem_purple", kind: .purple),
            GemDisplayItem(id: UUID(), imageName: "gem_orange", kind: .orange)
        ],
        canPlace: true,
        onTapGem: { _ in }
    )
    .padding()
}
