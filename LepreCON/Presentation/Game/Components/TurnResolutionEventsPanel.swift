//
// TurnResolutionEventsPanel.swift
// LepreCON
//
// Temporary end-of-turn feedback for unicorn and poop resolution.
//

import SwiftUI

struct TurnResolutionEventsPanel: View {
    let presentation: TurnResolutionEventPresentation
    var highlightedLineIndex: Int?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("What just happened")
                .font(.subheadline.weight(.semibold))

            VStack(alignment: .leading, spacing: 4) {
                ForEach(Array(presentation.logLines.enumerated()), id: \.offset) { index, line in
                    Text(line)
                        .font(.caption)
                        .foregroundStyle(index == highlightedLineIndex ? .primary : .secondary)
                        .fontWeight(index == highlightedLineIndex ? .semibold : .regular)
                }
            }

            ForEach(presentation.poopPreviews) { preview in
                VStack(alignment: .leading, spacing: 6) {
                    Text(preview.cupLabel)
                        .font(.caption.weight(.semibold))
                    GemCountListView(items: preview.gemCounts, style: .compact(gemSize: 22))
                }
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color.orange.opacity(0.12))
                )
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.purple.opacity(0.08))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.purple.opacity(0.25), lineWidth: 1)
        )
    }
}

#Preview {
    TurnResolutionEventsPanel(
        presentation: TurnResolutionEventPresentation(
            logLines: [
                "Unicorn exploded from Red",
                "Red gem moved to Orange",
                "Poop discarded C2"
            ],
            poopPreviews: [
                PoopDiscardPreviewDisplay(
                    id: 1,
                    cupLabel: "C2",
                    gemCounts: [
                        GemCountDisplayItem(kind: .red, count: 2),
                        GemCountDisplayItem(kind: .black, count: 1)
                    ]
                )
            ]
        ),
        highlightedLineIndex: 1
    )
    .padding()
}
