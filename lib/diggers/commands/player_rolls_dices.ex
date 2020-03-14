alias Commanded.Aggregate.Multi

defmodule Diggers.PlayerRollsDices do
  defstruct [:game_id, :dices_rolls]

  def execute(game, command) do
    cond do
      not Diggers.Game.exploration_phase?(game) ->
        {:error, :not_allowed_now}

      game.dices_rolls ->
        {:error, :dices_already_rolled}

      too_many_dices_rolls?(game, command.dices_rolls) ->
        {:error, :too_many_dices_rolls}

      true ->
        game
          |> Multi.new
          |> Multi.execute(&roll_dices(&1, command.dices_rolls))
          |> Multi.execute(&try_to_suffocate_players/1)
          |> Multi.execute(&try_to_kill_suffocated_players/1)
          |> Multi.execute(&try_to_end_game/1)
          |> Multi.execute(&try_to_end_round/1)
    end
  end

  defp roll_dices(game, dices_rolls) do
    %Diggers.DicesRolled{game_id: game.game_id, dices_rolls: dices_rolls}
  end


  defp try_to_suffocate_players(game) do
    game.players
      |> Enum.filter(fn (player_id) -> Enum.empty?(Diggers.Game.available_tiles_for_player(game, player_id)) end)
      |> Enum.map(fn (player_id) -> %Diggers.PlayerSuffocated{game_id: game.game_id, player_id: player_id} end)
  end


  defp try_to_kill_suffocated_players(game) do
    game.players
      |> Enum.filter(&Diggers.Game.player_died?(game, &1))
      |> Enum.map(fn (player_id) -> %Diggers.PlayerDied{game_id: game.game_id, player_id: player_id} end)
  end


  defp too_many_dices_rolls?(game, dices_rolls) do
    (4 - Enum.count(game.gone_players)) < Enum.count(dices_rolls)
  end


  def try_to_end_game(game) do
    if Diggers.Game.all_players_died?(game) do
      %Diggers.GameEnded{game_id: game.game_id, winners: Diggers.Game.winners_bis(game)}
    end
  end


  def try_to_end_round(game) do
    if game.phase == "exploration" and Diggers.Game.all_players_suffocated?(game) do
      IO.puts("NextExplorationRoundStarted")
      %Diggers.NextExplorationRoundStarted{game_id: game.game_id}
    end
  end
end
