//
// TurnResolutionEventDisplay.swift
// LepreCON
//
// Maps domain resolution events to temporary UI copy and gem badges.
//

import Foundation

struct PoopDiscardPreviewDisplay: Equatable, Identifiable {
    let id: Int
    let cupLabel: String
    let gemCounts: [GemCountDisplayItem]
}

struct TurnResolutionEventPresentation: Equatable {
    let logLines: [String]
    let poopPreviews: [PoopDiscardPreviewDisplay]
}

enum TurnResolutionEventDisplayBuilder {

    static func presentation(
        events: [TurnResolutionEvent],
        cups: [Cup]
    ) -> TurnResolutionEventPresentation? {
        guard !events.isEmpty else { return nil }

        var logLines: [String] = []
        var poopPreviews: [PoopDiscardPreviewDisplay] = []

        for event in events {
            switch event {
            case .unicornCalmed(let cupIndex):
                logLines.append("Unicorn calmed at \(cupLabel(forCupIndex: cupIndex, cups: cups))")
            case .unicornExplosionStarted(let fromCupIndex):
                logLines.append("Unicorn exploded from \(cupLabel(forCupIndex: fromCupIndex, cups: cups))")
            case .unicornExplosionStep(let gemKind, _, let toCupIndex):
                logLines.append(
                    "\(gemKind.displayName) gem moved to \(cupLabel(forCupIndex: toCupIndex, cups: cups))"
                )
            case .unicornMoved(let toCupIndex):
                logLines.append("Unicorn moved to \(cupLabel(forCupIndex: toCupIndex, cups: cups))")
            case .poopDiscardedCup(let cupIndex, let gems):
                let label = cupLabel(forCupIndex: cupIndex, cups: cups)
                logLines.append("Poop discarded \(label)")
                poopPreviews.append(
                    PoopDiscardPreviewDisplay(
                        id: cupIndex,
                        cupLabel: label,
                        gemCounts: GemCountDisplayBuilder.groupedCounts(from: gems)
                    )
                )
            case .poopResolved:
                break
            }
        }

        return TurnResolutionEventPresentation(logLines: logLines, poopPreviews: poopPreviews)
    }

    private static func cupLabel(forCupIndex index: Int, cups: [Cup]) -> String {
        GameBoardDisplayState.cupLabel(forCupIndex: index, cups: cups)
    }
}

private extension GemKind {
    var displayName: String {
        switch self {
        case .black: return "Poop"
        default: return rawValue.capitalized
        }
    }
}
