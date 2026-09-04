//
// DiscardPileView.swift
// LepreCON
//
// Persistent discard-pile control under the Pot of Gold.
// Presentation-only: shows count and active-destination state; legality lives in the domain.
//

import SwiftUI

/// Compact discard pile affordance on the board. Always visible; highlighted when it is the placement destination.
struct DiscardPileView: View {
    let discardCount: Int
    let isActiveDestination: Bool
    let width: CGFloat
    var onTap: () -> Void = {}

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "tray.full.fill")
                        .font(.system(size: max(16, width * 0.22), weight: .semibold))
                        .foregroundStyle(iconColor)
                        .frame(width: width * 0.42, height: width * 0.32)

                    Text("\(discardCount)")
                        .font(.system(size: max(10, width * 0.12), weight: .bold, design: .rounded))
                        .foregroundStyle(HUDFantasyText.valueColor)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(Color.black.opacity(0.6)))
                        .offset(x: 6, y: -8)
                }

                Text(statusLabel)
                    .font(.system(size: max(9, width * 0.11), weight: .heavy, design: .rounded))
                    .foregroundStyle(statusColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.65)
                    .hudReadableShadow()
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .frame(width: width)
            .background(background)
            .overlay(border)
            .shadow(
                color: isActiveDestination ? BoardStyle.d12GradientTop.opacity(0.55) : .clear,
                radius: isActiveDestination ? 8 : 0
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabelText)
        .accessibilityHint(accessibilityHintText)
        .accessibilityAddTraits(.isButton)
    }

    private var statusLabel: String {
        isActiveDestination ? "Discard 1 Gem" : "Discard"
    }

    private var iconColor: Color {
        isActiveDestination ? BoardStyle.d12GradientTop : HUDFantasyText.valueColor
    }

    private var statusColor: Color {
        isActiveDestination ? BoardStyle.d12GradientTop : HUDFantasyText.labelColor
    }

    private var background: some View {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
            .fill(Color.black.opacity(isActiveDestination ? 0.55 : 0.34))
    }

    private var border: some View {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
            .stroke(
                isActiveDestination
                    ? BoardStyle.d12GradientTop.opacity(0.95)
                    : BoardStyle.boardGoldOutline.opacity(0.55),
                lineWidth: isActiveDestination ? 2.25 : 1
            )
    }

    private var accessibilityLabelText: String {
        if isActiveDestination {
            return "Discard pile, \(discardCount) gems, discard one gem now"
        }
        return "Discard pile, \(discardCount) gems"
    }

    private var accessibilityHintText: String {
        "Shows gems currently in the discard pile"
    }
}
