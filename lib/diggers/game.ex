defmodule Diggers.Game do
  defstruct [
    :game_id,
    :players,
    :phase,
    :disabled_tiles,
    :disabled_tiles_this_round,
    :players_boards,
    :actions_this_round,
    :dices_rolls,
    :paths,
    :gone_players,
    :round,
    :lifes
  ]


  def execute(game, command) do
    command.__struct__.execute(game, command)
  end


  def apply(game, event) do
    event.__struct__.apply(game, event)
  end


  def has_player?(game, player_id) do
    Enum.member?(game.players, player_id)
  end


  def owner(game) do
    List.first(game.players)
  end


  def players_count(game) do
    Enum.count(game.players)
  end


  def disabling_phase?(game) do
    game.phase == "disabling"
  end


  def exploration_phase?(game) do
    game.phase == "exploration"
  end


  def lobby_phase?(game) do
    game.phase == "lobby"
  end


  def ended?(game) do
    game.phase == "results"
  end


  def can_disable_more_tiles?(game, player_id) do
    board_index = board_of_player(game, player_id)
    disabled_tiles = game.disabled_tiles_this_round[board_index]
    Enum.count(disabled_tiles) < 3
  end


  def disabled?(game, player_id, tile) do
    board_index = Diggers.Game.board_of_player(game, player_id)
    Enum.member?(game.disabled_tiles[board_index], tile) or Enum.member?(game.disabled_tiles_this_round[board_index], tile)
  end


  def board_of_player(game, player_id) do
    Enum.at(game.players_boards, index_of_player(game, player_id))
  end


  def index_of_player(game, player_id) do
    Enum.find_index(game.players, fn (some_player_id) -> some_player_id == player_id end)
  end


  def tile_of_player(game, player_id) do
    List.first(Enum.at(game.paths, index_of_player(game, player_id)))
  end


  def neighbours_of_player(game, player_id) do
    tile = tile_of_player(game, player_id)
    MapSet.new(Diggers.Tile.neighbours_of(tile))
  end


  def disabled_tiles_for_player(game, player_id) do
    board_index = board_of_player(game, player_id)
    MapSet.new(game.disabled_tiles[board_index])
  end


  def available_tiles_for_player(game, player_id) do
    neighbours_of_player(game, player_id)
      |> MapSet.difference(disabled_tiles_for_player(game, player_id))
      |> Enum.filter(&is_tile_available_with_dices_rolls?(&1, game.dices_rolls))
  end


  defp is_tile_available_with_dices_rolls?(tile, dices_rolls) do
    accepted_dices_rolls_for_tile = MapSet.new(Diggers.Tile.tiles[tile])
    dices_rolls = MapSet.new(dices_rolls || [])
    Enum.any?(MapSet.intersection(accepted_dices_rolls_for_tile, dices_rolls))
  end


  def player_left?(game, player_id) do
    game.gone_players[player_id]
  end


  def player_died?(game, player_id) do
    game.lifes[player_id] == 0
  end



  def already_moved?(game, player_id) do
    player_index = Diggers.Game.index_of_player(game, player_id)
    Enum.at(game.actions_this_round, player_index) != nil
  end


  def already_suffocated?(game, player_id) do
    player_index = Diggers.Game.index_of_player(game, player_id)
    Enum.at(game.actions_this_round, player_index) == "suffocation"
  end


  def winners(game) do
    if all_players_died?(game) do
      []
    else
      exit_bonuses = exit_bonuses(game.gone_players)

      Enum.map(Map.keys(game.gone_players), fn (player_id) ->
        diamonds_bonus = diamonds_bonus(game, player_id)
        exit_bonus = Map.get(exit_bonuses, player_id, 0)
        score = exit_bonus + diamonds_bonus
        {score, player_id}
      end) |> Enum.sort |> Enum.reverse
    end
  end


  defp diamonds_bonus(game, player_id) do
    player_index = Diggers.Game.index_of_player(game, player_id)
    player_path = Enum.at(game.paths, player_index)

    player_path
      |> Enum.uniq
      |> Enum.filter(&Diggers.Tile.diamond?/1)
      |> Enum.map(fn (_tile) -> 3 end)
      |> Enum.sum
  end


  defp exit_bonuses(gone_players) do
    bonuses = %{0 => 10, 1 => 5, 2 => 2}
    exit_rounds_with_index = Map.values(gone_players) |> Enum.uniq |> Enum.sort |> Enum.with_index
    bonus_by_exit_round = Enum.reduce(exit_rounds_with_index, %{}, fn ({exit_round, index}, memo) -> Map.put(memo, exit_round, Map.get(bonuses, index, 0)) end)

    Enum.reduce(gone_players, gone_players, fn ({player_id, exit_round}, memo) ->
      bonus = Map.get(bonus_by_exit_round, exit_round, 0)
      Map.put(memo, player_id, bonus)
    end)
  end


  def all_players_suffocated?(game) do
    Enum.all?(game.actions_this_round, fn (action) -> action == "suffocation" end)
  end


  def all_players_died?(game) do
    Enum.all?(game.players, &Diggers.Game.player_died?(game, &1))
  end
end
