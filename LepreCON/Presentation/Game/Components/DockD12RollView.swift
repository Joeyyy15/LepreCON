//
// DockD12RollView.swift
// LepreCON
//
// Center focus of the control dock: tap to roll D12 (SwiftUI placeholder art).
//

import SwiftUI

struct DockD12RollView: View {
    let showsRollControl: Bool
    let canRollD12: Bool
    let currentRoll: Int?
    var onRollD12: () -> Void = {}

    private let tileSize: CGFloat = 86

    var body: some View {
        VStack(spacing: 5) {
            if showsRollControl {
                Button(action: onRollD12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        BoardStyle.d12GradientTop,
                                        BoardStyle.d12GradientBottom
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: tileSize, height: tileSize)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(Color(red: 0.62, green: 0.42, blue: 0.06), lineWidth: 2.5)
                            )
                            .shadow(color: Color(red: 1.0, green: 0.85, blue: 0.3).opacity(canRollD12 ? 0.45 : 0.1), radius: 8, x: 0, y: 0)
                            .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 3)

                        Text(rollFaceText)
                            .font(.system(size: 32, weight: .black, design: .rounded))
                            .foregroundStyle(Color(red: 0.32, green: 0.18, blue: 0.04))
                            .minimumScaleFactor(0.5)
                    }
                }
                .buttonStyle(.plain)
                .disabled(!canRollD12)
                .opacity(canRollD12 ? 1 : 0.5)
                .scaleEffect(canRollD12 ? 1 : 0.94)

                Text("ROLL D12")
                    .font(.system(size: 11, weight: .heavy))
                    .foregroundStyle(BoardStyle.hudValue)
                    .shadow(color: .black.opacity(0.35), radius: 1, x: 0, y: 1)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var rollFaceText: String {
        if let currentRoll {
            return "\(currentRoll)"
        }
        return "D12"
    }
}
