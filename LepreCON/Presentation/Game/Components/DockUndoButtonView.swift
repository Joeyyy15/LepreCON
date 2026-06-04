//
// DockUndoButtonView.swift
// LepreCON
//
// Left section of the control dock: undo last placement.
//

import SwiftUI

struct DockUndoButtonView: View {
    let showsUndo: Bool
    let canUndo: Bool
    var compactOnArtBackground: Bool = false
    var onUndo: () -> Void = {}

    var body: some View {
        Group {
            if showsUndo {
                if compactOnArtBackground {
                    undoIconButton
                } else {
                    Button(action: onUndo) {
                        undoWithLabel
                    }
                    .buttonStyle(.plain)
                    .disabled(!canUndo)
                }
            }
        }
    }

    private var undoIconButton: some View {
        Button(action: onUndo) {
            Image(systemName: "arrow.uturn.backward.circle.fill")
                .font(.system(size: 34))
                .foregroundStyle(canUndo ? BoardStyle.hudValue : BoardStyle.hudTitle)
                .shadow(color: .black.opacity(0.45), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(.plain)
        .disabled(!canUndo)
        .accessibilityLabel("Undo last placement")
    }

    private var undoWithLabel: some View {
        VStack(spacing: 5) {
            Image(systemName: "arrow.uturn.backward.circle.fill")
                .font(.system(size: 30))
                .foregroundStyle(canUndo ? BoardStyle.hudValue : BoardStyle.hudTitle)

            Text("UNDO")
                .font(.system(size: 10, weight: .heavy))
                .foregroundStyle(canUndo ? BoardStyle.hudValue : BoardStyle.hudTitle)
        }
        .frame(width: 68, height: 80)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(BoardStyle.hudBadgeFill)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(BoardStyle.hudBadgeStroke, lineWidth: 0.85)
        )
        .accessibilityLabel("Undo last placement")
    }
}
