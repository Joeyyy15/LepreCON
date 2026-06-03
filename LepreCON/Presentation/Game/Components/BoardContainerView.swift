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
                    .stroke(BoardStyle.boardGoldOutline, lineWidth: 1.5)
            )
            .overlay(
                RoundedRectangle(cornerRadius: BoardStyle.cornerRadius - 2, style: .continuous)
                    .stroke(Color.black.opacity(0.35), lineWidth: 1)
                    .padding(2)
            )
            .shadow(color: .black.opacity(0.28), radius: 10, x: 0, y: 5)
    }

    private var boardPanelBackground: some View {
        ZStack {
            LinearGradient(
                colors: BoardStyle.boardSkyGradient,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            RadialGradient(
                colors: [
                    Color.white.opacity(0.12),
                    Color.clear
                ],
                center: .top,
                startRadius: 8,
                endRadius: 220
            )

            RoundedRectangle(cornerRadius: BoardStyle.cornerRadius, style: .continuous)
                .fill(Color.black.opacity(0.12))
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
