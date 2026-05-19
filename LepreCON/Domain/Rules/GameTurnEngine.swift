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
    /// the first placement cup (one counter-clockwise from the first white cup).
    static func beginTurn(session: inout GameSession, roll: Int) -> Result<Void, GameTurnError> {
        guard session.phase == .playing else { return .failure(.gameNotPlaying) }
        guard (1...12).contains(roll) else { return .failure(.invalidRoll) }
        guard session.currentRoll == nil else { return .failure(.turnAlreadyInProgress) }

        session.currentRoll = roll
        drawGemsIntoHand(session: &session, count: roll)
        session.nextPlacementCupIndex = GameSetup.firstPlacementCupIndex

        return .success(())
    }

    /// Places one gem from hand into the current cup and advances to the next cup clockwise.
    /// Does not run chain reactions yet.
    static func placeGemInCurrentCup(session: inout GameSession, gemID: UUID) -> Result<Void, GameTurnError> {
        guard session.phase == .playing else { return .failure(.gameNotPlaying) }
        guard hasActiveTurn(in: session) else { return .failure(.noActiveTurn) }
        guard let handIndex = session.gemsInHand.firstIndex(where: { $0.id == gemID }) else {
            return .failure(.gemNotInHand)
        }
        guard session.cups.indices.contains(session.nextPlacementCupIndex) else {
            return .failure(.invalidPlacementCupIndex)
        }
        
        let cupIndex = session.nextPlacementCupIndex
        
        // Chain reactions depend on whether the cup had gems before this gem was placed
        let cupHadGemsBeforePlacement = !session.cups[cupIndex].gems.isEmpty

        let gem = session.gemsInHand.remove(at: handIndex)
        
        // after removing the gem from hand, an empty hand means this was the final gem.
        let wasFinalGemInHand = session.gemsInHand.isEmpty
        
        session.cups[session.nextPlacementCupIndex].gems.append(gem)
        
        if wasFinalGemInHand && cupHadGemsBeforePlacement{
            // The final gem landed in a non-empty cup, so scoop the whole cup and continue.
            scoopCupIntoHand(session: &session, cupIndex: cupIndex)
            advancePlacementIndex(session: &session)
        } else if !wasFinalGemInHand{
            advancePlacementIndex(session: &session)
        }

        return .success(())
    }

    /// Places one gem from hand into the discard pile. Magic when landing in discard is not implemented.
    // TODO: Trigger magic resolution when the final gem of a turn lands in the discard pile.
    static func placeGemInDiscard(session: inout GameSession, gemID: UUID) -> Result<Void, GameTurnError> {
        guard session.phase == .playing else { return .failure(.gameNotPlaying) }
        guard hasActiveTurn(in: session) else { return .failure(.noActiveTurn) }
        guard let handIndex = session.gemsInHand.firstIndex(where: { $0.id == gemID }) else {
            return .failure(.gemNotInHand)
        }

        let gem = session.gemsInHand.remove(at: handIndex)
        session.discardPile.append(gem)

        return .success(())
    }

    // MARK: - Helpers

    /// True when a roll is recorded and the player still has gems to place.
    static func hasActiveTurn(in session: GameSession) -> Bool {
        session.currentRoll != nil && !session.gemsInHand.isEmpty
    }

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
