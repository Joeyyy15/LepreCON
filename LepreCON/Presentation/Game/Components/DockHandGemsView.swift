//
// DockHandGemsView.swift
// LepreCON
//
// Compact horizontal hand gems for the bottom control dock.
//

import SwiftUI

struct DockHandGemsView: View {
    let gemCounts: [GemCountDisplayItem]
    let canPlace: Bool
    var onTapKind: (GemKind) -> Void = { _ in }

    var body: some View {
        VStack(alignment: .trailing, spacing: 6) {
            Text("HAND")
                .font(.system(size: 10, weight: .heavy))
                .foregroundStyle(BoardStyle.hudValue)

            if gemCounts.isEmpty {
                Text("No gems")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(BoardStyle.hudTitle)
                    .frame(minHeight: 44)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(BoardStyle.hudBadgeFill.opacity(0.85))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(BoardStyle.hudBadgeStroke.opacity(0.5), lineWidth: 0.75)
                    )
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(gemCounts) { item in
                            Button {
                                onTapKind(item.kind)
                            } label: {
                                GemCountBadgeView(
                                    item: item,
                                    style: .hand(gemSize: 24),
                                    showsShortLabel: false
                                )
                                .padding(.horizontal, 7)
                                .padding(.vertical, 5)
                                .background(
                                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                                        .fill(Color.white.opacity(0.16))
                                )
                            }
                            .buttonStyle(.plain)
                            .disabled(!canPlace)
                        }
                    }
                }
                .frame(minHeight: 44)
            }
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
}
