//
// HUDStatBadgeView.swift
// LepreCON
//
// One compact stat chip in the gameplay HUD.
//

import SwiftUI

struct HUDStatBadgeView: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.system(size: 9, weight: .semibold))
                .foregroundStyle(BoardStyle.hudTitle)
                .lineLimit(1)

            Text(value)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(BoardStyle.hudValue)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .frame(minWidth: 44)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(BoardStyle.hudBadgeFill)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(BoardStyle.hudBadgeStroke, lineWidth: 0.75)
        )
    }
}
