//
// BottomBarArtBackground.swift
// LepreCON
//
// Decorative bottom control dock artwork (non-interactive).
//

import SwiftUI
import UIKit

struct BottomBarArtBackground: View {
    private static let assetName = "bottom_bar"

    var body: some View {
        Group {
            if UIImage(named: Self.assetName) != nil {
                Image(Self.assetName)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                RoundedRectangle(cornerRadius: BoardStyle.sceneChromeRadius, style: .continuous)
                    .fill(BoardStyle.dockPanelFill)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .allowsHitTesting(false)
    }
}
