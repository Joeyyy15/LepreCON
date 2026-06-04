//
// TopBarArtBackground.swift
// LepreCON
//
// Decorative top HUD bar artwork (non-interactive).
//

import SwiftUI
import UIKit

struct TopBarArtBackground: View {
    private static let assetName = "top_bar"

    var body: some View {
        Group {
            if UIImage(named: Self.assetName) != nil {
                Image(Self.assetName)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                RoundedRectangle(cornerRadius: BoardStyle.sceneChromeRadius, style: .continuous)
                    .fill(BoardStyle.hudPanelFill)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .allowsHitTesting(false)
    }
}
