//
// DockHandGemsView.swift
// LepreCON
//
// Hand gems for the bottom control dock.
//

import SwiftUI

struct DockHandGemsView: View {
    let gemCounts: [GemCountDisplayItem]
    let canPlace: Bool
    var compactOnArtBackground: Bool = false
    var onTapKind: (GemKind) -> Void = { _ in }

    private var gridColumnCount: Int {
        if compactOnArtBackground {
            return gemCounts.count <= 4 ? 2 : 3
        }
        return gemCounts.count <= 6 ? 3 : 4
    }

    private var handGemSize: CGFloat {
        if compactOnArtBackground {
            switch gemCounts.count {
            case 0...4: return 22
            case 5...8: return 18
            default: return 16
            }
        }
        switch gemCounts.count {
        case 0...6: return 26
        case 7...9: return 22
        default: return 18
        }
    }

    private var handCellMinHeight: CGFloat {
        if compactOnArtBackground {
            switch gemCounts.count {
            case 0...4: return 32
            case 5...8: return 28
            default: return 26
            }
        }
        switch gemCounts.count {
        case 0...6: return 44
        case 7...9: return 38
        default: return 34
        }
    }

    private var gridColumns: [GridItem] {
        Array(
            repeating: GridItem(.flexible(minimum: handGemSize + 4), spacing: 2),
            count: gridColumnCount
        )
    }

    var body: some View {
        Group {
            if compactOnArtBackground {
                handContentOnly
            } else {
                VStack(spacing: 4) {
                    HUDSectionLabel(text: "Hand")
                    handContentOnly
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    @ViewBuilder
    private var handContentOnly: some View {
        if gemCounts.isEmpty {
            Text("No gems")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(HUDFantasyText.labelColor)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .hudReadableShadow()
                .frame(maxWidth: .infinity, minHeight: handCellMinHeight, alignment: .center)
        } else {
            LazyVGrid(columns: gridColumns, alignment: .center, spacing: 2) {
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
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(BoardStyle.hudValue)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, minHeight: handCellMinHeight)
        .padding(.horizontal, 3)
        .padding(.vertical, 2)
        .background {
            if !compactOnArtBackground {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color.white.opacity(0.16))
            }
        }
        .overlay {
            if !compactOnArtBackground {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(BoardStyle.hudBadgeStroke.opacity(0.45), lineWidth: 0.75)
            }
        }
        .contentShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(item.displayName) \(item.count)")
        .accessibilityAddTraits(.isButton)
    }
}
