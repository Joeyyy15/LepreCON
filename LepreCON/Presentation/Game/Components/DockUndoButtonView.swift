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
    var onUndo: () -> Void = {}

    var body: some View {
        VStack(spacing: 5) {
            if showsUndo {
                Button(action: onUndo) {
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
                }
                .buttonStyle(.plain)
                .disabled(!canUndo)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
