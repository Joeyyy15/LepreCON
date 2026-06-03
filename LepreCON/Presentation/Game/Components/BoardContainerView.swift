//
// BoardContainerView.swift
// LepreCON
//
// Groups lanes, clouds, and pot on the scene without a heavy app-style panel.
//

import SwiftUI

struct BoardContainerView<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .padding(.vertical, 6)
            .frame(maxHeight: .infinity, alignment: .center)
            .background(BoardStyle.boardSceneVignette)
            .shadow(color: .black.opacity(0.2), radius: 14, x: 0, y: 6)
            .shadow(color: BoardStyle.boardPlayfieldGlow, radius: 18, x: 0, y: 0)
    }
}
