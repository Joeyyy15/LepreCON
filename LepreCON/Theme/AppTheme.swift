//
// AppTheme.swift
// LepreCON
//
// Shared styling constants: colors, spacing, and reusable button styles.
// Use these across Presentation layers for a consistent look.
//

import SwiftUI

// MARK: - Colors

enum AppTheme {
    /// Dark green background used for main screens.
    static let background = Color(red: 0.04, green: 0.20, blue: 0.12)

    /// Bright green accent for primary actions and highlights.
    static let accent = Color(red: 0.55, green: 0.93, blue: 0.68)

    /// Softer green for secondary elements and borders.
    static let accentMuted = Color(red: 0.45, green: 0.75, blue: 0.55)

    /// Primary text on dark background.
    static let textPrimary = Color.white

    /// Secondary text with reduced opacity.
    static let textSecondary = Color.white.opacity(0.85)

    /// Slightly lighter green for subtle gradients (e.g. top of screen depth).
    static let backgroundHighlight = Color(red: 0.06, green: 0.24, blue: 0.15)
}

// MARK: - Layout Constants

extension AppTheme {
    /// Standard horizontal padding for screen content.
    static let screenPaddingHorizontal: CGFloat = 24

    /// Standard vertical padding for screen content.
    static let screenPaddingVertical: CGFloat = 20

    /// Corner radius for cards and buttons.
    static let cornerRadius: CGFloat = 16

    /// Corner radius for icon buttons.
    static let iconButtonCornerRadius: CGFloat = 12

    /// Max content width for readability on large devices.
    static let maxContentWidth: CGFloat = 400

    /// Vertical spacing between menu items on Home.
    static let menuStackSpacing: CGFloat = 14

    /// Extra padding around the menu block for visual grouping.
    static let menuBlockPadding: CGFloat = 4
}

// MARK: - Button Styles

/// Filled primary button (e.g. secondary CTAs).
struct PrimaryButtonStyle: ButtonStyle {
    var background: Color = AppTheme.accent

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(Color.black.opacity(0.9))
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                    .fill(background)
            )
            .shadow(color: .black.opacity(0.25), radius: 14, x: 0, y: 10)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

/// Hero CTA for the main action (e.g. Play). Stronger shadow and subtle glow for hierarchy.
struct HeroButtonStyle: ButtonStyle {
    var background: Color = AppTheme.accent

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(Color.black.opacity(0.9))
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius + 2, style: .continuous)
                    .fill(background)
            )
            .shadow(color: AppTheme.accent.opacity(0.35), radius: 12, x: 0, y: 0)
            .shadow(color: .black.opacity(0.35), radius: 18, x: 0, y: 12)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

/// Outlined secondary button for menu items. Slightly raised feel with soft shadow.
struct SecondaryButtonStyle: ButtonStyle {
    var accent: Color = AppTheme.accent

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(AppTheme.textPrimary)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                    .fill(Color.white.opacity(configuration.isPressed ? 0.12 : 0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                            .stroke(accent.opacity(0.6), lineWidth: 1)
                    )
            )
            .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 4)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}
