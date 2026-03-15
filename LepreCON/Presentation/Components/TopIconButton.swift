//
// TopIconButton.swift
// LepreCON
//
// Reusable icon button for the top bar (e.g. Profile, Settings).
// Keeps header actions consistent and tappable with a clear hit area.
//

import SwiftUI

struct TopIconButton: View {
    let systemName: String
    let action: () -> Void

    private let size: CGFloat = 44
    private let iconSize: CGFloat = 22

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: iconSize, weight: .medium))
                .foregroundStyle(AppTheme.textPrimary)
                .frame(width: size, height: size)
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.iconButtonCornerRadius, style: .continuous)
                        .fill(Color.white.opacity(0.12))
                )
        }
        .buttonStyle(.plain)
    }
}

#Preview("TopIconButton") {
    ZStack {
        AppTheme.background.ignoresSafeArea()
        HStack(spacing: 16) {
            TopIconButton(systemName: "person.circle", action: {})
            TopIconButton(systemName: "gearshape", action: {})
        }
    }
}
