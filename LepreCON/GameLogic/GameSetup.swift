import Foundation

/// Creates a new game state and handles setup-related logic.
enum GameSetup {
    
    /// Builds a brand-new game with:
    /// - an empty default board
    /// - a shuffled starting gem bag
    /// - one starting gem placed in each normal cup
    /// - a random starting unicorn position
    static func makeNewGame() -> GameState {
        var board = Board.makeDefaultBoard()
        var bag = makeStartingBag()

        seedBoard(board: &board, bag: &bag)
        let unicornCupID = makeStartingUnicornCupID(from: board)

        return GameState(
            board: board,
            bag: bag,
            unicornCupID: unicornCupID,
            heldMagic: nil,
            completedColors: []
        )
    }

    /// Creates the starting gem bag for the game.
    ///
    /// Current version:
    /// - 10 of each rainbow color
    /// - 6 of each special gem type
    /// - shuffled before use
    ///
    /// This may need to be adjusted later if the official rule counts differ.
    private static func makeStartingBag() -> [GemType] {
        var bag: [GemType] = []

        for _ in 0..<10 {
            bag.append(.red)
            bag.append(.orange)
            bag.append(.yellow)
            bag.append(.green)
            bag.append(.blue)
            bag.append(.purple)
        }

        for _ in 0..<6 {
            bag.append(.white)
            bag.append(.black)
            bag.append(.gold)
            bag.append(.clear)
            bag.append(.pink)
        }

        return bag.shuffled()
    }

    /// Places one starting gem into each normal cup.
    ///
    /// This skips:
    /// - the pot of gold
    /// - the discard cup
    ///
    /// Current simplified rule:
    /// black gems are skipped during setup by drawing again.
    private static func seedBoard(board: inout Board, bag: inout [GemType]) {
        for index in board.cups.indices {
            if board.cups[index].type == .potOfGold || board.cups[index].type == .discard {
                continue
            }

            guard let drawnGem = drawNonBlackGem(from: &bag) else {
                return
            }

            board.cups[index].gems.append(drawnGem)
        }
    }

    /// Draws gems from the bag until a non-black gem is found.
    ///
    /// Current simplified behavior:
    /// black gems drawn during setup are removed from the bag instead of
    /// being returned and replaced. We can refine this later if needed.
    private static func drawNonBlackGem(from bag: inout [GemType]) -> GemType? {
        while !bag.isEmpty {
            let gem = bag.removeFirst()

            if gem != .black {
                return gem
            }
        }

        return nil
    }

    /// Chooses a random normal cup for the unicorn's starting position.
    ///
    /// The unicorn cannot start in:
    /// - the pot of gold
    /// - the discard cup
    private static func makeStartingUnicornCupID(from board: Board) -> Int? {
        let validCupIDs = board.cups
            .filter { $0.type != .potOfGold && $0.type != .discard }
            .map { $0.id }

        return validCupIDs.randomElement()
    }
}
