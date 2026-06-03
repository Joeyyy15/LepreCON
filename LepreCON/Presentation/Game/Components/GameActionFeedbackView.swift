//
// GameActionFeedbackView.swift
// LepreCON
//
// Slim toast-style feedback after taps (placement, roll, score, etc.).
//

import SwiftUI

struct GameActionFeedbackView: View {
    let message: String?

    var body: some View {
        if let message {
            Text(message)
                .font(.caption)
                .foregroundStyle(BoardStyle.hudValue)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    Capsule(style: .continuous)
                        .fill(BoardStyle.hudPanelFill.opacity(0.92))
                )
                .overlay(
                    Capsule(style: .continuous)
                        .stroke(BoardStyle.boardGoldOutline.opacity(0.65), lineWidth: 0.75)
                )
                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                .padding(.horizontal, 20)
        }
    }
}
