//
// GameTurnEngine.swift
// LepreCON
//
// Handles turn flow: D12 roll, drawing gems into hand, and placing gems one at a time
// around the cup circle. A full circuit of currently available cups requires exactly one
// discard before board placement resumes. End-of-turn resolution is delegated to
// EndOfTurnResolver.
// Magic, unicorn behavior, poop behavior, and player-confirmed scoring are not fully implemented yet.
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
    /// Current destination is discard; a cup placement is not legal.
    case placementRequiresDiscard
    /// Current destination is a cup; discard is not legal yet.
    case discardNotRequired
    /// A black/poop gem cannot be discarded during the required rotation discard.
    case cannotDiscardBlackGem
    /// Placement finished but the player must confirm or skip pending score choices first.
    case pendingScoreChoicesUnresolved
    /// A white-gem / unicorn decision must be resolved before placement or a new turn.
    case pendingWhiteGemDecisionUnresolved
}

/// Turn placement and drawing logic for LepreCON.
enum GameTurnEngine {

    // MARK: - Turn lifecycle

    /// True when the player may roll D12 (no active turn and no unresolved score choices).
    static func canRollD12(in session: GameSession) -> Bool {
        session.phase == .playing
            && !GameCompletionDetector.isGameOver(session: session)
            && !isTurnInProgress(in: session)
            && session.pendingScoreChoices.isEmpty
            && session.pendingWhiteGemDecision == nil
    }

    /// Starts a turn: records the D12 roll, draws gems from the bag into hand, and sets
    /// the first placement cup (first cloud after the pot of gold).
    static func beginTurn(session: inout GameSession, roll: Int) -> Result<Void, GameTurnError> {
        guard session.phase == .playing else { return .failure(.gameNotPlaying) }
        guard !GameCompletionDetector.isGameOver(session: session) else { return .failure(.gameNotPlaying) }
        guard (1...12).contains(roll) else { return .failure(.invalidRoll) }
        guard !isTurnInProgress(in: session) else { return .failure(.turnAlreadyInProgress) }
        guard session.pendingScoreChoices.isEmpty else { return .failure(.pendingScoreChoicesUnresolved) }
        guard session.pendingWhiteGemDecision == nil else { return .failure(.pendingWhiteGemDecisionUnresolved) }

        session.currentRoll = roll
        session.isTurnPlacementComplete = false
        session.placementsCompletedInCurrentRotation = 0
        session.recentResolutionEvents.removeAll()
        PendingScoreDetector.clearPendingScoreChoices(in: &session)
        drawGemsIntoHand(session: &session, count: roll)
        session.nextPlacementCupIndex = firstAvailablePlacementCupIndex(in: session)
            ?? GameSetup.firstPlacementCupIndex

        return .success(())
    }

    /// Places one gem from hand into the current cup.
    ///
    /// If this is not the final gem in hand, placement advances to the next cup.
    /// If this is the final gem in hand, the engine checks whether the cup
    /// already had gems before placement:
    /// - Empty before placement: the placement chain stops.
    /// - Not empty, and the cup has no white gem after placement: scoop and continue.
    /// - Not empty, and the cup contains white after placement: pause for a
    ///   player choice (scoop-and-continue vs use-white-to-end-turn).
    ///
    /// Completing a full rotation of available cups makes the next destination discard;
    /// that does not end placement by itself.
    static func placeGemInCurrentCup(session: inout GameSession, gemID: UUID) -> Result<Void, GameTurnError> {
        guard session.phase == .playing else { return .failure(.gameNotPlaying) }
        guard session.pendingWhiteGemDecision == nil else {
            return .failure(.pendingWhiteGemDecisionUnresolved)
        }
        guard canPlaceFromHand(in: session) else { return .failure(.noActiveTurn) }

        switch currentPlacementDestination(in: session) {
        case .discard:
            return .failure(.placementRequiresDiscard)
        case .cup(let expectedIndex):
            guard session.cups.indices.contains(expectedIndex) else {
                return .failure(.invalidPlacementCupIndex)
            }
            guard expectedIndex == session.nextPlacementCupIndex else {
                return .failure(.invalidPlacementCupIndex)
            }
        }

        guard let handIndex = session.gemsInHand.firstIndex(where: { $0.id == gemID }) else {
            return .failure(.gemNotInHand)
        }
        guard session.cups.indices.contains(session.nextPlacementCupIndex) else {
            return .failure(.invalidPlacementCupIndex)
        }

        let cupIndex = session.nextPlacementCupIndex
        guard !session.cups[cupIndex].isCompleted else {
            return .failure(.invalidPlacementCupIndex)
        }

        let cupHadGemsBeforePlacement = !session.cups[cupIndex].gems.isEmpty

        let gem = session.gemsInHand.remove(at: handIndex)
        let wasFinalGemInHand = session.gemsInHand.isEmpty

        session.cups[cupIndex].gems.append(gem)
        session.placementsCompletedInCurrentRotation += 1

        if wasFinalGemInHand && cupHadGemsBeforePlacement {
            if WhiteGemDecisionEngine.cupContainsWhiteGem(session.cups[cupIndex]) {
                session.pendingWhiteGemDecision = .endPlacementChain(cupIndex: cupIndex)
                return .success(())
            }
            scoopCupIntoHand(session: &session, cupIndex: cupIndex)
            advancePlacementIndex(session: &session)
        } else if wasFinalGemInHand {
            finishPlacementPhase(session: &session)
        } else {
            advancePlacementIndex(session: &session)
        }

        return .success(())
    }

    /// Moves exactly one gem from hand into the discard pile after a full board rotation.
    ///
    /// Discard is only legal when `currentPlacementDestination` is `.discard`.
    /// Black/poop gems (`GemKind.black`) cannot be discarded.
    /// After a successful discard, a new rotation begins at the already-advanced
    /// `nextPlacementCupIndex`. Discard alone does not trigger end-of-turn resolution
    /// unless the hand is empty afterward.
    static func placeGemInDiscard(session: inout GameSession, gemID: UUID) -> Result<Void, GameTurnError> {
        guard session.phase == .playing else { return .failure(.gameNotPlaying) }
        guard session.pendingWhiteGemDecision == nil else {
            return .failure(.pendingWhiteGemDecisionUnresolved)
        }
        guard canPlaceFromHand(in: session) else { return .failure(.noActiveTurn) }
        guard case .discard = currentPlacementDestination(in: session) else {
            return .failure(.discardNotRequired)
        }
        guard let handIndex = session.gemsInHand.firstIndex(where: { $0.id == gemID }) else {
            return .failure(.gemNotInHand)
        }
        guard canDiscardGemKind(session.gemsInHand[handIndex].kind) else {
            return .failure(.cannotDiscardBlackGem)
        }

        let gem = session.gemsInHand.remove(at: handIndex)
        session.discardPile.append(gem)
        session.placementsCompletedInCurrentRotation = 0

        if session.gemsInHand.isEmpty {
            finishPlacementPhase(session: &session)
        }

        return .success(())
    }

    // MARK: - Placement destination

    /// Domain-owned next legal placement target for the active turn.
    static func currentPlacementDestination(in session: GameSession) -> PlacementDestination {
        let availableCount = availablePlacementCupCount(in: session)
        if availableCount > 0,
           session.placementsCompletedInCurrentRotation >= availableCount {
            return .discard
        }
        return .cup(index: session.nextPlacementCupIndex)
    }

    /// True when the next required action is a rotation discard.
    static func isDiscardRequired(in session: GameSession) -> Bool {
        guard canPlaceFromHand(in: session) else { return false }
        if case .discard = currentPlacementDestination(in: session) {
            return true
        }
        return false
    }

    /// True when this gem kind may be discarded during a required rotation discard.
    /// Black/poop gems are never a legal rotation-discard choice.
    static func canDiscardGemKind(_ kind: GemKind) -> Bool {
        kind != .black
    }

    /// True when tapping this hand gem kind is a legal choice for the current destination.
    static func canSelectHandGemKind(_ kind: GemKind, in session: GameSession) -> Bool {
        guard canPlaceFromHand(in: session) else { return false }
        if isDiscardRequired(in: session) {
            return canDiscardGemKind(kind)
        }
        return true
    }

    /// Count of cups that currently accept normal placement (completed cups excluded).
    static func availablePlacementCupCount(in session: GameSession) -> Int {
        session.cups.reduce(0) { count, cup in
            count + (cup.isCompleted ? 0 : 1)
        }
    }

    // MARK: - Placement phase completion

    /// Marks placement finished and runs end-of-turn resolution (Unicorn → Poop → Score detection).
    private static func finishPlacementPhase(session: inout GameSession) {
        session.isTurnPlacementComplete = true
        EndOfTurnResolver.resolveAfterPlacementEnds(session: &session)
    }

    // MARK: - Turn state queries

    /// True while a turn roll is active and placement has not finished.
    static func isTurnInProgress(in session: GameSession) -> Bool {
        session.currentRoll != nil && !session.isTurnPlacementComplete
    }

    /// True when the player may place gems from hand (turn active and hand not empty).
    static func canPlaceFromHand(in session: GameSession) -> Bool {
        session.phase == .playing
            && !GameCompletionDetector.isGameOver(session: session)
            && isTurnInProgress(in: session)
            && !session.gemsInHand.isEmpty
            && session.pendingWhiteGemDecision == nil
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

    /// Moves placement to the next available cup clockwise, skipping completed cups.
    static func advancePlacementIndex(session: inout GameSession) {
        let cupCount = session.cups.count
        guard cupCount > 0 else { return }

        let nextStart = (session.nextPlacementCupIndex + 1) % cupCount
        guard let nextIndex = nextAvailablePlacementCupIndex(in: session, startingFrom: nextStart) else {
            // Every cup is completed — leave the index unchanged to avoid an infinite loop.
            return
        }
        session.nextPlacementCupIndex = nextIndex
    }

    /// First placement cup for a new turn, skipping any completed cups from the rulebook start index.
    static func firstAvailablePlacementCupIndex(in session: GameSession) -> Int? {
        nextAvailablePlacementCupIndex(in: session, startingFrom: GameSetup.firstPlacementCupIndex)
    }

    /// Next cup index that accepts gems, searching clockwise from `startingFrom` (inclusive).
    /// Returns nil when every cup on the board is completed.
    static func nextAvailablePlacementCupIndex(
        in session: GameSession,
        startingFrom: Int
    ) -> Int? {
        let cupCount = session.cups.count
        guard cupCount > 0 else { return nil }

        for offset in 0..<cupCount {
            let index = (startingFrom + offset) % cupCount
            if !session.cups[index].isCompleted {
                return index
            }
        }
        return nil
    }
}
