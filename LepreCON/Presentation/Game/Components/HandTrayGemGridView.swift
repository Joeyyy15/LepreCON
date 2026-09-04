//
// HandTrayGemGridView.swift
// LepreCON
//
// Scrollable grid of hand gems inside the bottom hand tray.
//

import SwiftUI

struct HandTrayGemGridView: View {
    let gemCounts: [GemCountDisplayItem]
    let canPlace: Bool
    /// When false, non-interactive cells keep full opacity (e.g. discard inspection).
    var showsDisabledAppearance: Bool = true
    var emptyMessage: String = "No gems"
    var gemSize: CGFloat = GameScreenLayout.handTrayGridGemSize
    var cellMinHeight: CGFloat = GameScreenLayout.handTrayGridCellMinHeight
    var onTapKind: (GemKind) -> Void = { _ in }

    private var gridColumns: [GridItem] {
        [
            GridItem(.adaptive(minimum: gemSize + 28), spacing: 10)
        ]
    }

    private var cellsAppearActive: Bool {
        canPlace || !showsDisabledAppearance
    }

    var body: some View {
        Group {
            if gemCounts.isEmpty {
                Text(emptyMessage)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(HUDFantasyText.labelColor)
                    .hudReadableShadow()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            } else {
                ScrollView {
                    LazyVGrid(columns: gridColumns, alignment: .center, spacing: 10) {
                        ForEach(gemCounts) { item in
                            if canPlace {
                                Button {
                                    onTapKind(item.kind)
                                } label: {
                                    handTrayGemCell(item)
                                }
                                .buttonStyle(.plain)
                            } else {
                                handTrayGemCell(item)
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                }
            }
        }
    }

    private func handTrayGemCell(_ item: GemCountDisplayItem) -> some View {
        VStack(spacing: 4) {
            GemView(imageName: item.imageName, size: gemSize)

            if let label = item.kind.handGemOverlayLabel {
                Text(label)
                    .font(.system(size: 9, weight: .heavy))
                    .foregroundStyle(BoardStyle.hudValue)
                    .lineLimit(1)
            }

            Text("×\(item.count)")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(BoardStyle.hudValue)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, minHeight: cellMinHeight)
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.white.opacity(cellsAppearActive ? 0.18 : 0.08))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(BoardStyle.hudBadgeStroke.opacity(cellsAppearActive ? 0.65 : 0.3), lineWidth: 1)
        )
        .opacity(cellsAppearActive ? 1 : 0.55)
        .contentShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(item.displayName) \(item.count)")
        .accessibilityAddTraits(canPlace ? .isButton : [])
    }
}
