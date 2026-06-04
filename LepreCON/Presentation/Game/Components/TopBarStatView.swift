//
// TopBarStatView.swift
// LepreCON
//
// Label + value overlays for blank top_bar stat wells.
//

import SwiftUI

/// Compact stat well (Score, Bag).
struct TopBarStatColumn: View {
    let label: String
    let value: String
    var compactValue: Bool = false

    var body: some View {
        VStack(spacing: 2) {
            Text(label.uppercased())
                .font(HUDFantasyText.labelFont)
                .foregroundStyle(HUDFantasyText.labelColor)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
                .hudReadableShadow()

            Text(value)
                .font(compactValue ? HUDFantasyText.compactValueFont : HUDFantasyText.valueFont)
                .foregroundStyle(HUDFantasyText.valueColor)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .hudReadableShadow()
        }
    }
}

/// Large right well: Rainbow label, count, and progress bar.
struct TopBarRainbowColumn: View {
    let completed: Int
    let total: Int

    private var progress: Double {
        guard total > 0 else { return 0 }
        return min(1, max(0, Double(completed) / Double(total)))
    }

    var body: some View {
        VStack(spacing: 3) {
            Text("RAINBOW")
                .font(HUDFantasyText.labelFont)
                .foregroundStyle(HUDFantasyText.labelColor)
                .lineLimit(1)
                .hudReadableShadow()

            Text("\(completed)/\(total)")
                .font(HUDFantasyText.valueFont)
                .foregroundStyle(HUDFantasyText.valueColor)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .hudReadableShadow()

            RainbowHUDProgressBar(progress: progress)
        }
    }
}

/// Horizontal rainbow completion bar (SwiftUI only).
struct RainbowHUDProgressBar: View {
    let progress: Double

    var body: some View {
        GeometryReader { geometry in
            let fillWidth = max(0, geometry.size.width * progress)
            ZStack(alignment: .leading) {
                Capsule(style: .continuous)
                    .fill(Color(red: 0.12, green: 0.22, blue: 0.42).opacity(0.9))
                    .overlay(
                        Capsule(style: .continuous)
                            .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
                    )

                Capsule(style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.45, green: 0.85, blue: 1.0),
                                Color(red: 0.95, green: 0.75, blue: 0.35)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: fillWidth)
                    .shadow(color: Color.cyan.opacity(0.35), radius: 2, x: 0, y: 0)
            }
        }
        .frame(height: 8)
    }
}

typealias TopBarStatView = TopBarStatColumn
