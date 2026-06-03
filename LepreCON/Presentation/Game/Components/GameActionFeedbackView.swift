//
// GameActionFeedbackView.swift
// LepreCON
//
// Short-lived player feedback after taps (placement, roll, score, etc.).
//

import SwiftUI

struct GameActionFeedbackView: View {
    let message: String?

    var body: some View {
        if let message {
            Text(message)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
        }
    }
}
