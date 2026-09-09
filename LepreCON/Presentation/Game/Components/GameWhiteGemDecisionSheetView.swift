//
// GameWhiteGemDecisionSheetView.swift
// LepreCON
//
// Player choices for a pending white-gem / unicorn decision.
// Both outcomes are chosen here; the domain applies them together.
//

import SwiftUI

struct GameWhiteGemDecisionSheetView: View {
    let cupLabel: String
    var onResolve: (_ triggerUnicorn: Bool, _ scoopAndContinue: Bool) -> Void = { _, _ in }

    @State private var triggerUnicorn = false
    @State private var scoopAndContinue = false

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                Text("A white gem is in \(cupLabel). Choose the unicorn outcome and whether to pick up this cup.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Unicorn")
                        .font(.headline)
                    Picker("Unicorn", selection: $triggerUnicorn) {
                        Text("Don't explode").tag(false)
                        Text("Explode").tag(true)
                    }
                    .pickerStyle(.segmented)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Cup")
                        .font(.headline)
                    Picker("Cup", selection: $scoopAndContinue) {
                        Text("Leave and end turn").tag(false)
                        Text("Pick up and continue").tag(true)
                    }
                    .pickerStyle(.segmented)
                }

                Button("Confirm") {
                    onResolve(triggerUnicorn, scoopAndContinue)
                }
                .buttonStyle(.borderedProminent)

                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .navigationTitle("White Gem")
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.medium, .large])
        .interactiveDismissDisabled()
    }
}
