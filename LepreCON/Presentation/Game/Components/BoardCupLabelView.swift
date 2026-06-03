//
// BoardCupLabelView.swift
// LepreCON
//
// Small gold-backed label plate for lane, cloud, and pot captions.
//

import SwiftUI

struct BoardCupLabelView: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.caption2.weight(.bold))
            .foregroundStyle(BoardStyle.labelText)
            .lineLimit(1)
            .minimumScaleFactor(0.75)
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .background(
                Capsule(style: .continuous)
                    .fill(BoardStyle.labelPlateFill)
            )
            .overlay(
                Capsule(style: .continuous)
                    .stroke(BoardStyle.labelPlateStroke, lineWidth: 0.75)
            )
    }
}
