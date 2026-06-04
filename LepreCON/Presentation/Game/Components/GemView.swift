//
//  GemView.swift
//  LepreCON
//
//  Reusable visual component for showing a gem image on the game board.
//

import SwiftUI
import UIKit

struct GemView: View {
    let imageName: String
    let size: CGFloat

    var body: some View {
        Image(GemView.resolvedAssetName(imageName))
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .shadow(color: .black.opacity(0.25), radius: size * 0.08, x: 0, y: size * 0.04)
            .accessibilityLabel("Gem")
    }

    /// Uses the requested asset when present; otherwise falls back to legacy gem images.
    static func resolvedAssetName(_ name: String) -> String {
        if UIImage(named: name) != nil {
            return name
        }
        switch name {
        case "gem_gold":
            return resolvedAssetName("gem_yellow")
        case "gem_clear":
            return resolvedAssetName("gem_white")
        default:
            return name
        }
    }
}

#Preview("Gem Assets") {
    VStack(spacing: 24) {
        Text("GemView Asset Preview")
            .font(.title2)
            .bold()

        HStack(spacing: 18) {
            GemView(imageName: "gem_red", size: 70)
            GemView(imageName: "gem_orange", size: 70)
            GemView(imageName: "gem_yellow", size: 70)
            GemView(imageName: "gem_green", size: 70)
        }

        HStack(spacing: 18) {
            GemView(imageName: "gem_blue", size: 70)
            GemView(imageName: "gem_purple", size: 70)
            GemView(imageName: "gem_white", size: 70)
            GemView(imageName: "gem_black", size: 70)
        }

        HStack(spacing: 18) {
            GemView(imageName: "gem_gold", size: 70)
            GemView(imageName: "gem_clear", size: 70)
        }
    }
    .padding(32)
    .background(.gray.opacity(0.15))
}
