defmodule Diggers.DisablingPhaseStarted do
  @derive Jason.Encoder
  defstruct [:game_id]


  def apply(game, _event) do
    %Diggers.Game{game |
      phase: "disabling",
      disabled_tiles: Diggers.Tile.blank_disabled_tiles(game.players),
      disabled_tiles_this_round: Diggers.Tile.blank_disabled_tiles(game.players),
      players_boards: Enum.map(0..(Enum.count(game.players) - 1), fn (index) -> index end)
    }
  end
end
