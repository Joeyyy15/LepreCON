//
// UnicornIndicatorView.swift
// LepreCON
//
// Temporary unicorn marker on a cup/lane. Polished visuals come later.
//

import SwiftUI

struct UnicornIndicatorView: View {
    var body: some View {
        VStack(spacing: 2) {
            Text("🦄")
                .font(.title3)

            Text("UNICORN")
                .font(.system(size: 8, weight: .heavy))
                .tracking(0.5)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(Color.white.opacity(0.95))
        )
        .overlay(
            Capsule()
                .stroke(Color.purple.opacity(0.85), lineWidth: 2)
        )
        .shadow(color: .black.opacity(0.35), radius: 3, x: 0, y: 2)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Unicorn on this cup")
    }
}

#Preview {
    ZStack {
        RoundedRectangle(cornerRadius: 20)
            .fill(.red)
            .frame(width: 48, height: 200)
        UnicornIndicatorView()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding(.top, 6)
    }
    .padding()
}
