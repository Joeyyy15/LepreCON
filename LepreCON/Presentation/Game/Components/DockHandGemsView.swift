//
// DockHandGemsView.swift
// LepreCON
//
// Hand gems for the bottom control dock: centered title and wrapping grid.
//

import SwiftUI

struct DockHandGemsView: View {
    let gemCounts: [GemCountDisplayItem]
    let canPlace: Bool
    var onTapKind: (GemKind) -> Void = { _ in }

    private var gridColumnCount: Int {
        gemCounts.count <= 6 ? 3 : 4
    }

    private var handGemSize: CGFloat {
        switch gemCounts.count {
        case 0...6: return 26
        case 7...9: return 22
        default: return 18
        }
    }

    private var handCellMinHeight: CGFloat {
        switch gemCounts.count {
        case 0...6: return 44
        case 7...9: return 38
        default: return 34
        }
    }

    private var gridColumns: [GridItem] {
        Array(
            repeating: GridItem(.flexible(minimum: handGemSize + 6), spacing: 3),
            count: gridColumnCount
        )
    }

    var body: some View {
        VStack(spacing: 4) {
            Text("HAND")
                .font(.system(size: 10, weight: .heavy))
                .foregroundStyle(BoardStyle.hudValue)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .center)

            if gemCounts.isEmpty {
                noGemsPlaceholder
            } else {
                LazyVGrid(columns: gridColumns, alignment: .center, spacing: 3) {
                    ForEach(gemCounts) { item in
                        Button {
                            onTapKind(item.kind)
                        } label: {
                            handGemCell(item)
                        }
                        .buttonStyle(.plain)
                        .disabled(!canPlace)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    private var noGemsPlaceholder: some View {
        Text("No gems")
            .font(.system(size: 11, weight: .medium))
            .foregroundStyle(BoardStyle.hudTitle)
            .lineLimit(1)
            .minimumScaleFactor(0.8)
            .frame(maxWidth: .infinity, minHeight: 44, alignment: .center)
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
    }

    private func handGemCell(_ item: GemCountDisplayItem) -> some View {
        VStack(spacing: 2) {
            GemView(imageName: item.imageName, size: handGemSize)

            if let label = item.kind.handGemOverlayLabel {
                Text(label)
                    .font(.system(size: 7, weight: .heavy))
                    .foregroundStyle(BoardStyle.hudValue)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }

            Text("×\(item.count)")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(BoardStyle.hudValue)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, minHeight: handCellMinHeight)
        .padding(.horizontal, 4)
        .padding(.vertical, 3)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color.white.opacity(0.16))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(BoardStyle.hudBadgeStroke.opacity(0.45), lineWidth: 0.75)
        )
        .contentShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(item.displayName) \(item.count)")
        .accessibilityAddTraits(.isButton)
    }
}

#Preview("Hand — grouped") {
    DockHandGemsView(
        gemCounts: [
            GemCountDisplayItem(kind: .red, count: 3),
            GemCountDisplayItem(kind: .gold, count: 2),
            GemCountDisplayItem(kind: .clear, count: 1),
            GemCountDisplayItem(kind: .black, count: 1)
        ],
        canPlace: true
    )
    .frame(width: GameScreenLayout.dockHandSectionWidth)
    .padding(8)
    .background(BoardStyle.dockPanelFill)
}

#Preview("Hand — empty") {
    DockHandGemsView(gemCounts: [], canPlace: false)
        .frame(width: GameScreenLayout.dockHandSectionWidth)
        .padding(8)
        .background(BoardStyle.dockPanelFill)
}
