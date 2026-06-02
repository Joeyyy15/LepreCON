//
// UnicornResolver.swift
// LepreCON
//
// End-of-turn unicorn resolution: white gems calm the unicorn; otherwise gems
// explode clockwise into following cups. Does not trigger normal chain reactions.
//

import Foundation

/// What happened when unicorn resolution ran.
enum UnicornResolutionOutcome: Equatable {
    case noUnicorn
    case noGemsToExplode
    case calmedByWhite(cupIndex: Int)
    case exploded(fromCupIndex: Int, finalCupIndex: Int?)
}

/// Resolves unicorn behavior at end of turn (before poop and score detection).
enum UnicornResolver {

    /// Applies unicorn rules to the session. Returns what happened for tests and debugging.
    @discardableResult
    static func resolve(in session: inout GameSession) -> UnicornResolutionOutcome {
        guard let unicornIndex = session.unicornCupIndex else {
            return .noUnicorn
        }
        guard session.cups.indices.contains(unicornIndex) else {
            return .noUnicorn
        }

        let cupGems = session.cups[unicornIndex].gems

        // White calms the unicorn: one white gem is spent to discard; cup does not explode.
        if let whiteIndex = cupGems.firstIndex(where: { $0.kind == .white }) {
            let whiteGem = session.cups[unicornIndex].gems.remove(at: whiteIndex)
            session.discardPile.append(whiteGem)
            return .calmedByWhite(cupIndex: unicornIndex)
        }

        // Nothing to spread — unicorn stays put.
        guard !cupGems.isEmpty else {
            return .noGemsToExplode
        }

        return explodeGems(fromCupIndex: unicornIndex, in: &session)
    }

    // MARK: - Explosion

    /// Takes all gems from the unicorn cup and spreads them one-by-one clockwise.
    private static func explodeGems(
        fromCupIndex unicornIndex: Int,
        in session: inout GameSession
    ) -> UnicornResolutionOutcome {
        let gemsToSpread = session.cups[unicornIndex].gems
        session.cups[unicornIndex].gems.removeAll()

        let cupCount = session.cups.count
        var spreadFrom = (unicornIndex + 1) % cupCount
        var finalCupIndex: Int?

        for gem in gemsToSpread {
            guard let targetIndex = GameTurnEngine.nextAvailablePlacementCupIndex(
                in: session,
                startingFrom: spreadFrom
            ) else {
                // Every cup is completed — gem has nowhere to land; return it to the unicorn cup.
                session.cups[unicornIndex].gems.append(gem)
                continue
            }

            session.cups[targetIndex].gems.append(gem)
            finalCupIndex = targetIndex
            spreadFrom = (targetIndex + 1) % cupCount
        }

        // Unicorn follows the last gem that landed; if none landed, stay on the empty cup.
        if let finalCupIndex {
            syncUnicorn(to: finalCupIndex, in: &session)
        }

        return .exploded(fromCupIndex: unicornIndex, finalCupIndex: finalCupIndex)
    }

    private static func syncUnicorn(to cupIndex: Int, in session: inout GameSession) {
        session.unicornCupIndex = cupIndex
        session.unicornCupID = session.cups[cupIndex].id
    }
}
