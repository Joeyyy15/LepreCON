import Foundation

/// Temporary sandbox for manually testing game logic while building the engine.
enum GameLogicSandbox {

    /// Shows the board and the drawn hand before a gem is chosen.
    static func previewTurnStart() -> String {
        var state = GameSetup.makeNewGame()

        guard let turn = TurnBuilder.makeTurn(drawCount: 3, state: &state) else {
            return "Could not start turn."
        }

        return """
        TURN START

        \(TurnStateDebugger.summary(for: turn))

        \(GameStateDebugger.summary(for: state))
        """
    }

    /// Creates a new game, starts a turn, places one chosen gem, and returns a readable summary.
    static func runSingleTurnExample(chosenGemIndex: Int = 0) -> String {
        var state = GameSetup.makeNewGame()

        guard var turn = TurnBuilder.makeTurn(drawCount: 3, state: &state) else {
            return "Could not start turn."
        }

        let beforePlacement = TurnStateDebugger.summary(for: turn)

        TurnPlacer.placeChosenGem(
            at: chosenGemIndex,
            turn: &turn,
            on: &state.board
        )

        let afterPlacement = TurnStateDebugger.summary(for: turn)

        return """
        CHOSEN GEM INDEX: \(chosenGemIndex)

        BEFORE PLACEMENT
        \(beforePlacement)

        AFTER PLACEMENT
        \(afterPlacement)

        \(GameStateDebugger.summary(for: state))
        """
    }
}
