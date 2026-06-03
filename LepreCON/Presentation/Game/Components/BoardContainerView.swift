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
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}
