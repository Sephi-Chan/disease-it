defmodule Diggers.ExplorationPhaseStarted do
  @derive Jason.Encoder
  defstruct [:game_id, :board, :disabled_tiles]


  def apply(game, event) do
    %Diggers.Game{game |
      phase: "exploration",
      disabled_tiles: event.disabled_tiles,
      board: event.board,
      paths: List.duplicate([Diggers.Board.start_tile(event.board)], Enum.count(game.players)),
      gone_players: %{},
      lifes: Enum.reduce(game.players, %{}, fn (player_id, memo) -> Map.put(memo, player_id, 5) end ),
      round: 1
    }
  end
end
