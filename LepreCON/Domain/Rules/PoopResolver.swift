//
// PoopResolver.swift
// LepreCON
//
// End-of-turn black gem (poop) resolution: every gem in a poop cup goes to discard.
//

import Foundation

/// One cup whose contents were discarded because it contained poop.
struct DiscardedPoopCup: Equatable {
    let cupIndex: Int
    let discardedCount: Int
}

/// What happened when poop resolution ran.
enum PoopResolutionOutcome: Equatable {
    case noPoop
    case discardedCups([DiscardedPoopCup])
}

/// Resolves black gem / poop behavior at end of turn (after unicorn, before score detection).
enum PoopResolver {

    /// Discards all gems in every non-completed cup that contains at least one black gem.
    @discardableResult
    static func resolve(in session: inout GameSession) -> PoopResolutionOutcome {
        var discardedCups: [DiscardedPoopCup] = []

        for cupIndex in session.cups.indices {
            let cup = session.cups[cupIndex]
            guard !cup.isCompleted else { continue }
            guard cup.gems.contains(where: { $0.kind == .black }) else { continue }

            let gemsToDiscard = session.cups[cupIndex].gems
            session.discardPile.append(contentsOf: gemsToDiscard)
            session.cups[cupIndex].gems.removeAll()
            session.recentResolutionEvents.append(
                .poopDiscardedCup(cupIndex: cupIndex, discardedGems: gemsToDiscard)
            )

            discardedCups.append(
                DiscardedPoopCup(cupIndex: cupIndex, discardedCount: gemsToDiscard.count)
            )
        }

        guard !discardedCups.isEmpty else {
            return .noPoop
        }
        session.recentResolutionEvents.append(.poopResolved)
        return .discardedCups(discardedCups)
    }
}
