//
// PlaceholderDestinationView.swift
// LepreCON
//
// Lightweight placeholder screen for Home destinations (Profile, Settings, etc.).
// Shows a clear title and a back button; no feature logic. Replace with real
// feature views when implementing each screen.
//

import SwiftUI

struct PlaceholderDestinationView: View {
    let destination: HomeDestination
    let onDismiss: () -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()

                VStack(spacing: 16) {
                    Text("Coming soon")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(AppTheme.textSecondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .navigationTitle(destination.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(AppTheme.background, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Back") {
                        onDismiss()
                    }
                    .foregroundStyle(AppTheme.accent)
                }
            }
        }
    }
}

#Preview("Profile") {
    PlaceholderDestinationView(destination: .profile, onDismiss: {})
}

#Preview("The Stable") {
    PlaceholderDestinationView(destination: .theStable, onDismiss: {})
}
