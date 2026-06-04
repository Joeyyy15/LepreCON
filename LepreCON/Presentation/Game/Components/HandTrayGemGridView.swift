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
    var onTapKind: (GemKind) -> Void = { _ in }

    private var gridColumns: [GridItem] {
        [
            GridItem(.adaptive(minimum: GameScreenLayout.handTrayGridGemSize + 28), spacing: 10)
        ]
    }

    var body: some View {
        Group {
            if gemCounts.isEmpty {
                Text("No gems")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(HUDFantasyText.labelColor)
                    .hudReadableShadow()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            } else {
                ScrollView {
                    LazyVGrid(columns: gridColumns, alignment: .center, spacing: 10) {
                        ForEach(gemCounts) { item in
                            Button {
                                onTapKind(item.kind)
                            } label: {
                                handTrayGemCell(item)
                            }
                            .buttonStyle(.plain)
                            .disabled(!canPlace)
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
            GemView(imageName: item.imageName, size: GameScreenLayout.handTrayGridGemSize)

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
        .frame(maxWidth: .infinity, minHeight: GameScreenLayout.handTrayGridCellMinHeight)
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.white.opacity(canPlace ? 0.18 : 0.08))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(BoardStyle.hudBadgeStroke.opacity(canPlace ? 0.65 : 0.3), lineWidth: 1)
        )
        .opacity(canPlace ? 1 : 0.55)
        .contentShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(item.displayName) \(item.count)")
        .accessibilityAddTraits(.isButton)
    }
}
