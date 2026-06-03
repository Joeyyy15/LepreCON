//
// UnicornIndicatorView.swift
// LepreCON
//
// Compact corner badge for the unicorn. Does not cover cup gem counts.
//

import SwiftUI

struct UnicornIndicatorView: View {
    var body: some View {
        Text("U")
            .font(.system(size: 10, weight: .black))
            .foregroundStyle(.purple)
            .padding(.horizontal, 5)
            .padding(.vertical, 3)
            .background(
                Capsule()
                    .fill(Color.white.opacity(0.95))
            )
            .overlay(
                Capsule()
                    .stroke(Color.purple, lineWidth: 1.5)
            )
            .shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: 1)
            .accessibilityLabel("Unicorn")
    }
}

#Preview {
    ZStack(alignment: .topTrailing) {
        RoundedRectangle(cornerRadius: 12)
            .fill(.white)
            .frame(width: 80, height: 54)
        UnicornIndicatorView()
            .padding(3)
    }
    .padding()
}
