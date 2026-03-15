//
// HowToPlayView.swift
// LepreCON
//
// Dedicated How To Play screen with structured sections. Content is driven by
// HowToPlaySection so real rules can replace placeholder text later without changing layout.
//

import SwiftUI

// MARK: - Content Model (swap placeholder strings for real rules later)

struct HowToPlaySection: Identifiable {
    let id: String
    let title: String
    let body: String
}

/// Placeholder instructional content. Replace with real rules/copy when ready.
private enum HowToPlayContent {
    static let sections: [HowToPlaySection] = [
        HowToPlaySection(
            id: "overview",
            title: "Overview",
            body: "LepreCON is a party game for groups. Placeholder: add a short overview of the game and what players do."
        ),
        HowToPlaySection(
            id: "setup",
            title: "Setup",
            body: "Placeholder: describe how to set up the game—number of players, choosing difficulty, dealing cards or assigning roles, etc."
        ),
        HowToPlaySection(
            id: "turn",
            title: "How a Turn Works",
            body: "Placeholder: explain the flow of a single turn—what each player does, how prompts or challenges work, and how turns alternate."
        ),
        HowToPlaySection(
            id: "winning",
            title: "Winning / End Conditions",
            body: "Placeholder: describe how the game ends and how a winner (or winning team) is determined."
        ),
        HowToPlaySection(
            id: "tips",
            title: "Tips",
            body: "Placeholder: optional tips for new players—house rules, pacing, or things to keep in mind."
        )
    ]
}

// MARK: - View

struct HowToPlayView: View {
    let onDismiss: () -> Void

    private let sectionSpacing: CGFloat = 24
    private let titleFontSize: CGFloat = 20
    private let bodyFontSize: CGFloat = 16

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: sectionSpacing) {
                    ForEach(HowToPlayContent.sections) { section in
                        sectionView(section)
                    }
                }
                .padding(.horizontal, AppTheme.screenPaddingHorizontal)
                .padding(.vertical, 20)
                .padding(.bottom, 32)
            }
            .background(AppTheme.background)
            .navigationTitle("How To Play")
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

    private func sectionView(_ section: HowToPlaySection) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(section.title)
                .font(.system(size: titleFontSize, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.textPrimary)

            Text(section.body)
                .font(.system(size: bodyFontSize, weight: .regular))
                .foregroundStyle(AppTheme.textSecondary)
                .lineSpacing(6)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                .fill(Color.white.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                        .stroke(AppTheme.accent.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Previews

#Preview("How To Play") {
    HowToPlayView(onDismiss: {})
}
