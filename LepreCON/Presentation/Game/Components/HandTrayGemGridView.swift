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
    /// Domain-derived per-kind legality. Used only when `canPlace` is true.
    var isKindSelectable: (GemKind) -> Bool = { _ in true }
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

    private func isSelectable(_ kind: GemKind) -> Bool {
        canPlace && isKindSelectable(kind)
    }

    private func cellAppearsActive(for kind: GemKind) -> Bool {
        isSelectable(kind) || !showsDisabledAppearance
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
                            if isSelectable(item.kind) {
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
        let appearsActive = cellAppearsActive(for: item.kind)
        return VStack(spacing: 4) {
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
                .fill(Color.white.opacity(appearsActive ? 0.18 : 0.08))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(BoardStyle.hudBadgeStroke.opacity(appearsActive ? 0.65 : 0.3), lineWidth: 1)
        )
        .opacity(appearsActive ? 1 : 0.55)
        .contentShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(item.displayName) \(item.count)")
        .accessibilityAddTraits(isSelectable(item.kind) ? .isButton : [])
    }
}
