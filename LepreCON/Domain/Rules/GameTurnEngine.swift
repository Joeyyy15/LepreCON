//
// GameTurnEngine.swift
// LepreCON
//
// Handles turn flow: D12 roll, drawing gems into hand, and placing gems one at a time
// around the cup circle. Chain reactions, magic, scoring, and unicorn rules are not here yet.
//

import Foundation

/// Errors that can occur while applying turn actions to a session.
enum GameTurnError: Error, Equatable {
    case gameNotPlaying
    case invalidRoll
    case turnAlreadyInProgress
    case noActiveTurn
    case gemNotInHand
    case invalidPlacementCupIndex
}

/// Turn placement and drawing logic for LepreCON.
enum GameTurnEngine {

    // MARK: - Turn lifecycle

    /// Starts a turn: records the D12 roll, draws gems from the bag into hand, and sets
    /// the first placement cup (first cloud after the pot of gold).
    static func beginTurn(session: inout GameSession, roll: Int) -> Result<Void, GameTurnError> {
        guard session.phase == .playing else { return .failure(.gameNotPlaying) }
        guard (1...12).contains(roll) else { return .failure(.invalidRoll) }
        guard !isTurnInProgress(in: session) else { return .failure(.turnAlreadyInProgress) }

        session.currentRoll = roll
        session.isTurnPlacementComplete = false
        drawGemsIntoHand(session: &session, count: roll)
        session.nextPlacementCupIndex = GameSetup.firstPlacementCupIndex

        return .success(())
    }

    /// Places one gem from hand into the current cup.
    ///
    /// If this is not the final gem in hand, placement advances to the next cup.
    /// If this is the final gem in hand, the engine checks whether the cup
    /// already had gems before placement:
    /// - Empty before placement: the placement chain stops.
    /// - Not empty before placement: scoop the whole cup into hand and continue.
    static func placeGemInCurrentCup(session: inout GameSession, gemID: UUID) -> Result<Void, GameTurnError> {
        guard session.phase == .playing else { return .failure(.gameNotPlaying) }
        guard canPlaceFromHand(in: session) else { return .failure(.noActiveTurn) }
        guard let handIndex = session.gemsInHand.firstIndex(where: { $0.id == gemID }) else {
            return .failure(.gemNotInHand)
        }
        guard session.cups.indices.contains(session.nextPlacementCupIndex) else {
            return .failure(.invalidPlacementCupIndex)
        }

        let cupIndex = session.nextPlacementCupIndex
        let cupHadGemsBeforePlacement = !session.cups[cupIndex].gems.isEmpty

        let gem = session.gemsInHand.remove(at: handIndex)
        let wasFinalGemInHand = session.gemsInHand.isEmpty

        session.cups[cupIndex].gems.append(gem)

        if wasFinalGemInHand && cupHadGemsBeforePlacement {
            scoopCupIntoHand(session: &session, cupIndex: cupIndex)
            advancePlacementIndex(session: &session)
        } else if wasFinalGemInHand {
            session.isTurnPlacementComplete = true
            // TODO: End-of-turn resolution order — Unicorn → Poop → Score.
        } else {
            advancePlacementIndex(session: &session)
        }

        return .success(())
    }

    /// Moves a gem from hand into the discard pile.
    ///
    /// **Not a current player action.** After rolling the D12, the player chooses which gem to
    /// place on the board path; they cannot manually discard from hand. Reserved for future
    /// rules (e.g. magic when the final gem of a turn resolves to the discard pile).
    static func placeGemInDiscard(session: inout GameSession, gemID: UUID) -> Result<Void, GameTurnError> {
        guard session.phase == .playing else { return .failure(.gameNotPlaying) }
        guard canPlaceFromHand(in: session) else { return .failure(.noActiveTurn) }
        guard let handIndex = session.gemsInHand.firstIndex(where: { $0.id == gemID }) else {
            return .failure(.gemNotInHand)
        }

        let gem = session.gemsInHand.remove(at: handIndex)
        session.discardPile.append(gem)

        if session.gemsInHand.isEmpty {
            session.isTurnPlacementComplete = true
            // TODO: End-of-turn resolution order — Unicorn → Poop → Score (magic on discard).
        }

        return .success(())
    }

    // MARK: - Turn state queries

    /// True while a turn roll is active and placement has not finished.
    static func isTurnInProgress(in session: GameSession) -> Bool {
        session.currentRoll != nil && !session.isTurnPlacementComplete
    }

    /// True when the player may place gems from hand (turn active and hand not empty).
    static func canPlaceFromHand(in session: GameSession) -> Bool {
        isTurnInProgress(in: session) && !session.gemsInHand.isEmpty
    }

    // MARK: - Helpers

    /// Draws up to `count` gems from the bag into the player's hand (never exceeds bag size).
    static func drawGemsIntoHand(session: inout GameSession, count: Int) {
        let drawCount = min(count, session.gemsInBag.count)
        guard drawCount > 0 else { return }

        let drawn = session.gemsInBag.prefix(drawCount)
        session.gemsInHand.append(contentsOf: drawn)
        session.gemsInBag.removeFirst(drawCount)
    }

    /// Moves every gem from a cup into the player's hand and leaves the cup empty.
    static func scoopCupIntoHand(session: inout GameSession, cupIndex: Int) {
        guard session.cups.indices.contains(cupIndex) else { return }

        let scoopedGems = session.cups[cupIndex].gems
        session.gemsInHand.append(contentsOf: scoopedGems)
        session.cups[cupIndex].gems.removeAll()
    }

    /// Moves placement to the next cup clockwise, wrapping from last cup to first.
    static func advancePlacementIndex(session: inout GameSession) {
        let cupCount = session.cups.count
        guard cupCount > 0 else { return }
        session.nextPlacementCupIndex = (session.nextPlacementCupIndex + 1) % cupCount
    }
}
