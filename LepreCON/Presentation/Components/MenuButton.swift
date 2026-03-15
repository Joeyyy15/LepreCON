//
// MenuButton.swift
// LepreCON
//
// Reusable large menu button for the Home screen list (The Stable, How To Play, etc.).
// Uses theme secondary style for a consistent, scalable menu.
//

import SwiftUI

struct MenuButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(AppTheme.textPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
        }
        .buttonStyle(SecondaryButtonStyle())
    }
}

#Preview("MenuButton") {
    ZStack {
        AppTheme.background.ignoresSafeArea()
        VStack(spacing: 12) {
            MenuButton(title: "The Stable", action: {})
            MenuButton(title: "How To Play", action: {})
        }
        .frame(width: 320)
    }
}
