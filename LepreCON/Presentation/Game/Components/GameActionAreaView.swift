//
// GameActionAreaView.swift
// LepreCON
//
// Primary turn action (Roll D12).
//

import SwiftUI

struct GameActionAreaView: View {
    let showsRollButton: Bool
    let canRollD12: Bool
    var onRollD12: () -> Void = {}

    var body: some View {
        if showsRollButton {
            Button("Roll D12", action: onRollD12)
                .buttonStyle(.borderedProminent)
                .disabled(!canRollD12)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
