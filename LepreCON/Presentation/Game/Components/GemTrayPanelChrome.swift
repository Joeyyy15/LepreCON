//
// GemTrayPanelChrome.swift
// LepreCON
//
// Shared visual chrome for Hand and Discard gem container panels.
//

import SwiftUI

enum GemTrayPanelChrome {
    static let cornerRadius: CGFloat = 18

    static var background: some View {
        ZStack {
            LinearGradient(
                colors: [
                    BoardStyle.hudPanelFill.opacity(0.98),
                    Color(red: 0.05, green: 0.09, blue: 0.18).opacity(0.96)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            LinearGradient(
                colors: [
                    Color(red: 0.55, green: 0.38, blue: 0.12).opacity(0.22),
                    Color.clear
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    static func borderStroke(isEmphasized: Bool) -> some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .stroke(
                isEmphasized
                    ? BoardStyle.d12GradientTop.opacity(0.9)
                    : BoardStyle.boardGoldOutline.opacity(0.55),
                lineWidth: isEmphasized ? 1.75 : 1.25
            )
    }
}
