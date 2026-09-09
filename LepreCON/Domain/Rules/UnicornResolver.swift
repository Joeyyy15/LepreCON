//
// UnicornResolver.swift
// LepreCON
//
// End-of-turn unicorn resolution. A white gem in the unicorn cup no longer
// auto-calms; callers pause for a pending player decision instead.
// Explosion still spreads gems clockwise and does not trigger chain reactions.
//

import Foundation

/// What happened when unicorn resolution ran.
enum UnicornResolutionOutcome: Equatable {
    case noUnicorn
    case noGemsToExplode
    /// Unicorn cup contains a white gem; the player must choose before resolving.
    case awaitingPlayerDecision(cupIndex: Int)
    case calmedByWhite(cupIndex: Int)
    case exploded(fromCupIndex: Int, finalCupIndex: Int?)
}

/// Resolves unicorn behavior at end of turn (before poop and score detection),
/// unless a white gem requires a pending player decision.
enum UnicornResolver {

    /// True when the unicorn cup currently contains a white gem that must be decided by the player.
    static func requiresPlayerDecision(in session: GameSession) -> Bool {
        guard let unicornIndex = session.unicornCupIndex,
              session.cups.indices.contains(unicornIndex) else {
            return false
        }
        return session.cups[unicornIndex].gems.contains(where: { $0.kind.calmsUnicorn })
    }

    /// Applies automatic unicorn rules when no white-gem decision is required.
    /// If a white gem is present, records no board mutation and returns `.awaitingPlayerDecision`.
    @discardableResult
    static func resolve(in session: inout GameSession) -> UnicornResolutionOutcome {
        guard let unicornIndex = session.unicornCupIndex else {
            return .noUnicorn
        }
        guard session.cups.indices.contains(unicornIndex) else {
            return .noUnicorn
        }

        if requiresPlayerDecision(in: session) {
            return .awaitingPlayerDecision(cupIndex: unicornIndex)
        }

        let cupGems = session.cups[unicornIndex].gems

        // Nothing to spread — unicorn stays put.
        guard !cupGems.isEmpty else {
            return .noGemsToExplode
        }

        return explodeGems(fromCupIndex: unicornIndex, in: &session)
    }

    /// Player chose not to explode: discard exactly one white gem and leave the unicorn in place.
    @discardableResult
    static func calm(in session: inout GameSession) -> UnicornResolutionOutcome {
        guard let unicornIndex = session.unicornCupIndex,
              session.cups.indices.contains(unicornIndex),
              let calmingIndex = indexOfWhiteGemThatCalmsUnicorn(in: session.cups[unicornIndex].gems)
        else {
            return resolve(in: &session)
        }

        let whiteGem = session.cups[unicornIndex].gems.remove(at: calmingIndex)
        session.discardPile.append(whiteGem)
        record(.unicornCalmed(cupIndex: unicornIndex), in: &session)
        return .calmedByWhite(cupIndex: unicornIndex)
    }

    /// Player chose to explode even though a white gem is present (or explode with no white gem).
    @discardableResult
    static func explode(in session: inout GameSession) -> UnicornResolutionOutcome {
        guard let unicornIndex = session.unicornCupIndex else {
            return .noUnicorn
        }
        guard session.cups.indices.contains(unicornIndex) else {
            return .noUnicorn
        }

        let cupGems = session.cups[unicornIndex].gems
        guard !cupGems.isEmpty else {
            return .noGemsToExplode
        }

        return explodeGems(fromCupIndex: unicornIndex, in: &session)
    }

    /// Index of a white gem that can calm the unicorn. Clear gems are never calming.
    private static func indexOfWhiteGemThatCalmsUnicorn(in gems: [Gem]) -> Int? {
        gems.firstIndex(where: { $0.kind.calmsUnicorn })
    }

    // MARK: - Explosion

    /// Takes all gems from the unicorn cup and spreads them one-by-one clockwise.
    private static func explodeGems(
        fromCupIndex unicornIndex: Int,
        in session: inout GameSession
    ) -> UnicornResolutionOutcome {
        let gemsToSpread = session.cups[unicornIndex].gems
        session.cups[unicornIndex].gems.removeAll()
        record(.unicornExplosionStarted(fromCupIndex: unicornIndex), in: &session)

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
                record(
                    .unicornExplosionStep(
                        gemKind: gem.kind,
                        fromCupIndex: unicornIndex,
                        toCupIndex: unicornIndex
                    ),
                    in: &session
                )
                continue
            }

            session.cups[targetIndex].gems.append(gem)
            record(
                .unicornExplosionStep(
                    gemKind: gem.kind,
                    fromCupIndex: unicornIndex,
                    toCupIndex: targetIndex
                ),
                in: &session
            )
            finalCupIndex = targetIndex
            spreadFrom = (targetIndex + 1) % cupCount
        }

        // Unicorn follows the last gem that landed; if none landed, stay on the empty cup.
        if let finalCupIndex {
            syncUnicorn(to: finalCupIndex, in: &session)
            record(.unicornMoved(toCupIndex: finalCupIndex), in: &session)
        }

        return .exploded(fromCupIndex: unicornIndex, finalCupIndex: finalCupIndex)
    }

    private static func record(_ event: TurnResolutionEvent, in session: inout GameSession) {
        session.recentResolutionEvents.append(event)
    }

    private static func syncUnicorn(to cupIndex: Int, in session: inout GameSession) {
        session.unicornCupIndex = cupIndex
        session.unicornCupID = session.cups[cupIndex].id
    }
}
