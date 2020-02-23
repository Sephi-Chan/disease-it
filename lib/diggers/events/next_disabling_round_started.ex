defmodule Diggers.NextDisablingRoundStarted do
  @derive Jason.Encoder
  defstruct [:game_id, :players_boards]


  def apply(game, event) do
    game
      |> rotate_board_indexes(event)
      |> save_disabled_tiles
  end


  defp rotate_board_indexes(game, event) do
    %Diggers.Game{game | players_boards: event.players_boards}
  end


  defp save_disabled_tiles(game) do
    player_indexes = 0..(Enum.count(game.players) - 1)

    %Diggers.Game{game |
      disabled_tiles_this_round: Enum.reduce(player_indexes, %{}, fn (index, disabled_tiles) -> Map.put(disabled_tiles, index, []) end),
      disabled_tiles: Enum.reduce(game.disabled_tiles_this_round, game.disabled_tiles, fn ({board_index, disabled_tiles}, all_disabled_tiles) ->
        update_in(all_disabled_tiles, [board_index], fn (tiles) -> tiles ++ disabled_tiles end)
      end)
    }
  end
end
