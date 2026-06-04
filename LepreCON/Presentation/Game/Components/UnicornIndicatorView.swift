//
// UnicornIndicatorView.swift
// LepreCON
//
// Compact corner marker for the unicorn cup. Uses the "unicorn" asset;
// does not cover cup gem counts.
//

import SwiftUI
import UIKit

struct UnicornIndicatorView: View {
    /// Visible marker size (aspect-fit within this square).
    static let markerSize: CGFloat = 52

    private static let assetName = "unicorn"

    var body: some View {
        Group {
            if UIImage(named: Self.assetName) != nil {
                Image(Self.assetName)
                    .resizable()
                    .scaledToFit()
            } else {
                legacyPlaceholder
            }
        }
        .frame(width: Self.markerSize, height: Self.markerSize)
        .shadow(color: .black.opacity(0.32), radius: 3, x: 0, y: 2)
        .shadow(color: .white.opacity(0.4), radius: 1.5, x: 0, y: 0)
        .accessibilityLabel("Unicorn")
    }

    private var legacyPlaceholder: some View {
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
