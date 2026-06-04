//
// MagicSlotPlaceholderView.swift
// LepreCON
//
// Center magic slot placeholder for the top HUD bar.
//

import SwiftUI

struct MagicSlotPlaceholderView: View {
    var body: some View {
        VStack(spacing: 2) {
            Text("MAGIC")
                .font(.system(size: 7, weight: .heavy, design: .rounded))
                .foregroundStyle(HUDFantasyText.labelColor)
                .lineLimit(1)
                .hudReadableShadow()

            Text("Coming Soon")
                .font(.system(size: 7, weight: .bold, design: .rounded))
                .foregroundStyle(HUDFantasyText.valueColor)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.7)
                .hudReadableShadow()
        }
        .accessibilityLabel("Magic slot, coming soon")
    }
}
