//
// BoardContainerView.swift
// LepreCON
//
// Single rounded panel that visually groups lanes, clouds, and pot.
//

import SwiftUI

struct BoardContainerView<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .padding(BoardStyle.panelPadding)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .background(boardPanelBackground)
            .clipShape(RoundedRectangle(cornerRadius: BoardStyle.cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: BoardStyle.cornerRadius, style: .continuous)
                    .stroke(Color.white.opacity(BoardStyle.panelStrokeOpacity), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
    }

    private var boardPanelBackground: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.purple.opacity(0.32),
                    Color.indigo.opacity(0.24),
                    Color.cyan.opacity(0.18)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            RoundedRectangle(cornerRadius: BoardStyle.cornerRadius, style: .continuous)
                .fill(Color.white.opacity(BoardStyle.panelFillOpacity))
        }
    }
}

#Preview("Board Container") {
    BoardContainerView {
        Text("Board content")
            .frame(height: 200)
    }
    .padding()
    .frame(height: 260)
    .background(Color.gray.opacity(0.15))
}
