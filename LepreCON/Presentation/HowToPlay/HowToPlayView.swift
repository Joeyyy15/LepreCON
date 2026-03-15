//
// HowToPlayView.swift
// LepreCON
//
// Clean scrolling How To Play screen.
// Content is structured in readable sections with simple headers and body text.
//

import SwiftUI

struct HowToPlaySection: Identifiable {
    let id: String
    let title: String
    let body: String
}

private enum HowToPlayContent {
    static let sections: [HowToPlaySection] = [
        HowToPlaySection(
            id: "overview",
            title: "Overview",
            body: """
            In LepreCON, your goal is to bring the rainbow back together by collecting all six rainbow colors in groups of five. Along the way, you can also collect gold for bonus points, manage your unicorn, and avoid black gems, which count as poop. Completing all six colors wins the game.
            """
        ),
        HowToPlaySection(
            id: "setup",
            title: "Setup",
            body: """
            Place the cups in a circle with the Pot of Gold in the correct spot. Put all gems into the bag and, without looking, place one gem into each cup. If a black gem appears during setup, redraw so the game does not begin with poop already in play. Roll the D12 to place the unicorn, rerolling if needed based on the setup rules.
            """
        ),
        HowToPlaySection(
            id: "turns",
            title: "How a Turn Works",
            body: """
            Roll the D12, then draw that many gems from the bag. Starting with the cup one space to the left of the Pot of Gold, place one gem into each cup moving clockwise. Once a gem is placed, it stays there.

            If the final gem lands in a cup that already contains gems, pick up all gems from that cup and continue placing them around the circle. Keep going until the final gem lands in an empty cup or in the discard pile. After placement ends, resolve any special effects before checking for scoring.
            """
        ),
        HowToPlaySection(
            id: "scoring",
            title: "Scoring",
            body: """
            You score a color when a cup contains at least five usable gems of that color after accounting for blemishes. A blemish is any gem in that cup that does not match the color you are trying to score.

            White and gold can help as passes, and clear gems can become any color you choose. If a color is scored in its matching colored cup, that score is doubled. Gold collected in scored cups moves to the Pot of Gold.
            """
        ),
        HowToPlaySection(
            id: "winning",
            title: "Winning and Bonus Points",
            body: """
            Each completed color is worth 1 point, for up to 6 points total. If a color is collected in its corresponding colored cup, its value is doubled. Gold in the Pot of Gold is worth 1 point per piece, and capturing the unicorn in a scoring cup is worth 3 points.

            However, you only earn gold and unicorn bonus points if the rainbow is fully completed. A perfect score is 24.
            """
        ),
        HowToPlaySection(
            id: "special-gems",
            title: "Special Gems",
            body: """
            White gems can stop a chain reaction if the final gem lands on a pile with white, and they can also calm the unicorn. Black gems are poop. When your turn ends, everything in the same cup as the poop is discarded.

            Gold goes to the Pot of Gold and does not count toward a color. Clear gems become any color you choose. Pink gems keep their color, but are usually more awkward than helpful.
            """
        ),
        HowToPlaySection(
            id: "unicorn",
            title: "The Unicorn",
            body: """
            The unicorn can only be calmed by a white gem or by being captured in a cup that is successfully scored. If the unicorn is in a cup that scores, keep it with that cup and gain the capture bonus.

            If the unicorn is not captured, it explodes the colors in that cup down the line. That explosion does not continue the normal chain reaction.
            """
        ),
        HowToPlaySection(
            id: "magic",
            title: "Magic and Manipulation",
            body: """
            Magic is triggered whenever the final gem of your turn lands in the discard pile. When that happens, roll the D12 again and gain the matching magic effect.

            You may hold only one magic at a time, and you can use it later when it helps most. Effects include removing gems, reversing placement order, swapping cups, moving all gold to the Pot of Gold, searching the bag for a color, and choosing any power.
            """
        ),
        HowToPlaySection(
            id: "tips",
            title: "Helpful Tips",
            body: """
            Gold and white gems can often help a cup without blemishing it. Pink gems are usually low-value and can be treated like easy discards. Do not throw away too many of the same color or you may make the rainbow impossible to complete.

            You can score in the white cups. Sometimes the best move is saving a magic instead of using it immediately, and sometimes the unicorn is more useful as a tool than a threat.
            """
        )
    ]
}

struct HowToPlayView: View {
    let onDismiss: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 28) {
                    headerSection

                    ForEach(HowToPlayContent.sections) { section in
                        sectionView(section)
                    }
                }
                .padding(.horizontal, AppTheme.screenPaddingHorizontal)
                .padding(.top, 20)
                .padding(.bottom, 40)
            }
            .background(AppTheme.background.ignoresSafeArea())
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

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Learn the rules")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.textPrimary)

            Text("A quick guide to setup, turns, scoring, the unicorn, and special gems.")
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(AppTheme.textSecondary)
                .lineSpacing(4)
        }
        .padding(.bottom, 4)
    }

    private func sectionView(_ section: HowToPlaySection) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(section.title)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.textPrimary)

            Text(section.body)
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(AppTheme.textSecondary)
                .lineSpacing(6)
                .fixedSize(horizontal: false, vertical: true)

            Rectangle()
                .fill(AppTheme.accent.opacity(0.18))
                .frame(height: 1)
                .padding(.top, 4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview("How To Play") {
    HowToPlayView(onDismiss: {})
}

