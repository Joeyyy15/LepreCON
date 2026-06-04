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
                    .scaleEffect(1)   // makes the visible bar art bigger
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()           // hides overflow after scaling
            } else {
                RoundedRectangle(cornerRadius: BoardStyle.sceneChromeRadius, style: .continuous)
                    .fill(BoardStyle.hudPanelFill)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .allowsHitTesting(false)
    }
}
