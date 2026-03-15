//
// PromoArea.swift
// LepreCON
//
// Small placeholder area near the bottom of the Home screen for future
// newsletter, other games, or website content. Layout stays compact and mobile-friendly.
//

import SwiftUI

struct PromoArea: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("More from us")
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(AppTheme.textSecondary)

            Text("Newsletter · Games · Website")
                .font(.system(size: 11, weight: .regular))
                .foregroundStyle(AppTheme.textSecondary.opacity(0.8))
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.iconButtonCornerRadius, style: .continuous)
                .fill(Color.white.opacity(0.08))
        )
    }
}

#Preview("PromoArea") {
    ZStack {
        AppTheme.background.ignoresSafeArea()
        PromoArea()
            .frame(width: 160)
    }
}
