defmodule Diggers.DisablingPhaseStarted do
  @derive Jason.Encoder
  defstruct [:game_id, :players_boards, :board]


  def apply(game, event) do
    %Diggers.Game{game |
      phase: "disabling",
      disabled_tiles: Diggers.Tile.blank_disabled_tiles(game.players),
      disabled_tiles_this_round: Diggers.Tile.blank_disabled_tiles(game.players),
      players_boards: event.players_boards,
      board: event.board
    }
  end
end
