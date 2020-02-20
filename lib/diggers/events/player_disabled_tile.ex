defmodule Diggers.PlayerDisabledTile do
  @derive Jason.Encoder
  defstruct [:game_id, :player_id, :tile]


  def apply(game, event) do
    tile = Diggers.Tile.parse(event.tile)
    board_index = Diggers.Game.board_of_player(game, event.player_id)

    %Diggers.Game{game |
      disabled_tiles_this_round: update_in(game.disabled_tiles_this_round, [board_index], fn (disabled_tiles) ->
        disabled_tiles ++ [tile]
      end)
    }
  end
end
