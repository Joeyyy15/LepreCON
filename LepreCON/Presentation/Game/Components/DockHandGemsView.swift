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
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .trailing)

            if gemCounts.isEmpty {
                Text("No gems")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(BoardStyle.hudTitle)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .frame(maxWidth: .infinity, minHeight: 44, alignment: .trailing)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(BoardStyle.hudBadgeFill.opacity(0.9))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(BoardStyle.hudBadgeStroke.opacity(0.55), lineWidth: 0.75)
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
                                    style: .hand(gemSize: 22),
                                    showsShortLabel: false
                                )
                                .padding(.horizontal, 5)
                                .padding(.vertical, 4)
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
