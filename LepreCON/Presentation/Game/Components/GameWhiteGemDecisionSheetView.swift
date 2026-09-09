//
// GameWhiteGemDecisionSheetView.swift
// LepreCON
//
// Presents the currently pending white-gem context. Placement-chain and unicorn
// spread are separate decisions; this view does not combine them.
//

import SwiftUI

struct GameWhiteGemDecisionSheetView: View {
    let decision: PendingWhiteGemDecision
    let cupLabel: String
    var onScoopAndContinue: () -> Void = {}
    var onUseWhiteToEndTurn: () -> Void = {}
    var onExplodeUnicorn: () -> Void = {}
    var onCalmUnicorn: () -> Void = {}

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text(prompt)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                switch decision {
                case .endPlacementChain:
                    Button("Scoop and continue placing") {
                        onScoopAndContinue()
                    }
                    .buttonStyle(.borderedProminent)

                    Button("Use white to end the turn") {
                        onUseWhiteToEndTurn()
                    }
                    .buttonStyle(.bordered)

                case .stopUnicornSpread:
                    Button("Explode the unicorn") {
                        onExplodeUnicorn()
                    }
                    .buttonStyle(.borderedProminent)

                    Button("Use white to calm the unicorn") {
                        onCalmUnicorn()
                    }
                    .buttonStyle(.bordered)
                }

                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.medium, .large])
        .interactiveDismissDisabled()
    }

    private var title: String {
        switch decision {
        case .endPlacementChain: return "White Gem"
        case .stopUnicornSpread: return "Unicorn"
        }
    }

    private var prompt: String {
        switch decision {
        case .endPlacementChain:
            return "\(cupLabel) contains a white gem. Scoop every gem and keep placing, or discard one white to end the turn."
        case .stopUnicornSpread:
            return "The unicorn's cup (\(cupLabel)) contains a white gem. Explode/spread, or discard one white to keep the unicorn here."
        }
    }
}
