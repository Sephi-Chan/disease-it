alias Commanded.Aggregate.Multi

defmodule Diggers.PlayerDisablesTile do
  defstruct [:game_id, :player_id, :tile]


  def execute(game, command) do
    tile = Diggers.Tile.parse(command.tile)

    cond do
      not Diggers.Game.has_player?(game, command.player_id) ->
        {:error, :player_not_found}

      not Diggers.Game.disabling_phase?(game) ->
        {:error, :not_allowed_now}

      not Diggers.Tile.on_board?(tile) ->
        {:error, :tile_not_found}

      Diggers.Tile.start?(tile) or Diggers.Tile.exit?(tile) or Diggers.Tile.diamond?(tile) ->
        {:error, :not_allowed_on_special_tiles}

      Diggers.Game.disabled?(game, command.player_id, tile) ->
        {:error, :already_disabled}

      tile_has_disabled_neighbour?(game, command.player_id, tile) ->
        {:error, :neighbour_already_disabled}

      not Diggers.Game.can_disable_more_tiles?(game, command.player_id) ->
        {:error, :no_more_disabling_allowed}

      true ->
        game
          |> Multi.new
          |> Multi.execute(&disable_tile(&1, command.player_id, command.tile))
          |> Multi.execute(&try_to_start_next_disabling_round/1)
          |> Multi.execute(&try_to_start_exploration_phase/1)
    end
  end


  defp disable_tile(game, player_id, tile) do
    %Diggers.PlayerDisabledTile{game_id: game.game_id, tile: tile, player_id: player_id}
  end


  defp try_to_start_next_disabling_round(game) do
    if all_players_disabled_three_tiles_this_round?(game) do
      %Diggers.NextDisablingRoundStarted{game_id: game.game_id}
    end
  end


  defp try_to_start_exploration_phase(game) do
    if all_tiles_have_been_disabled?(game) do
      %Diggers.ExplorationPhaseStarted{game_id: game.game_id}
    end
  end


  defp all_players_disabled_three_tiles_this_round?(game) do
    Enum.all?(game.disabled_tiles_this_round, fn ({_board_index, disabled_tiles}) ->
      Enum.count(disabled_tiles) == 3
    end)
  end


  defp all_tiles_have_been_disabled?(game) do
    Enum.all?(game.disabled_tiles, fn ({_board_index, disabled_tiles}) ->
      Enum.count(disabled_tiles) == 3 * Enum.count(game.players)
    end)
  end


  defp tile_has_disabled_neighbour?(game, player_id, tile) do
    Diggers.Tile.neighbours_of(tile)
      |> Enum.any?(&Diggers.Game.disabled?(game, player_id, &1))
  end
end
