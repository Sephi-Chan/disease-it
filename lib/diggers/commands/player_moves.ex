alias Commanded.Aggregate.Multi

defmodule Diggers.PlayerMoves do
  defstruct [:game_id, :player_id, :tile]

  def execute(game, command) do
    tile = Diggers.Tile.parse(command.tile)

    cond do
      not Diggers.Game.has_player?(game, command.player_id) ->
        {:error, :player_not_found}

      not Diggers.Game.exploration_phase?(game) ->
        {:error, :not_allowed_now}

      Diggers.Game.player_died?(game, command.player_id) ->
        {:error, :player_is_dead}

      Diggers.Game.player_left?(game, command.player_id) ->
        {:error, :player_already_left}

      Diggers.Game.already_suffocated?(game, command.player_id) ->
        {:error, :suffocated_this_round}

      Diggers.Game.already_moved?(game, command.player_id) ->
        {:error, :already_moved_this_round}

      not tile_in_neighbours?(game, command.player_id, tile) ->
        {:error, :tile_not_in_neighbours}

      Diggers.Game.disabled?(game, command.player_id, tile) ->
        {:error, :tile_is_disabled}

      not tile_is_available?(game, command.player_id, tile) ->
        {:error, :tile_is_unavailable}

      true ->
        game
          |> Multi.new
          |> Multi.execute(&move_player(&1, command.player_id, command.tile))
          |> Multi.execute(&try_to_exit(&1, command.player_id, tile))
          |> Multi.execute(&try_to_end_game/1)
          |> Multi.execute(&try_to_end_round/1)
    end
  end


  defp tile_in_neighbours?(game, player_id, tile) do
    neighbours = Diggers.Game.neighbours_of_player(game, player_id)
    Enum.member?(neighbours, tile)
  end


  def tile_is_available?(game, player_id, tile) do
    available_tiles = Diggers.Game.available_tiles_for_player(game, player_id)
    Enum.member?(available_tiles, tile)
  end


  def move_player(game, player_id, tile) do
    %Diggers.PlayerMoved{game_id: game.game_id, player_id: player_id, tile: tile}
  end


  def try_to_exit(game, player_id, tile) do
    if tile == Diggers.Tile.exit_tile do
      %Diggers.PlayerLeft{game_id: game.game_id, player_id: player_id}
    end
  end


  def try_to_end_game(game) do
    if Enum.count(game.players) == Enum.count(game.gone_players) do
      %Diggers.GameEnded{game_id: game.game_id}
    end
  end


  def try_to_end_round(game) do
    if game.phase == "exploration" and Enum.all?(game.actions_this_round) do
      %Diggers.NextExplorationRoundStarted{game_id: game.game_id}
    end
  end
end
