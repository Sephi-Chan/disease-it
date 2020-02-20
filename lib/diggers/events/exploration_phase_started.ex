defmodule Diggers.ExplorationPhaseStarted do
  @derive Jason.Encoder
  defstruct [:game_id]


  def apply(game, _event) do
    %Diggers.Game{game |
      phase: "exploration",
      disabled_tiles_this_round: Diggers.Tile.blank_disabled_tiles(game.players),
      paths: List.duplicate([Diggers.Tile.start_tile], Enum.count(game.players)),
      gone_players: %{},
      lifes: Enum.reduce(game.players, %{}, fn (player_id, memo) -> Map.put(memo, player_id, 5) end ),
      round: 1
    }
  end
end
