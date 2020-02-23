defmodule Diggers.PlayerStartsGame do
  defstruct [:game_id, :player_id]

  def execute(game, command) do
    cond do
      Diggers.Game.owner(game) != command.player_id ->
        {:error, :not_allowed}

      not Diggers.Game.lobby_phase?(game) ->
        {:error, :not_allowed_now}

      Diggers.Game.players_count(game) < 2 ->
        {:error, :not_enough_players}

      true ->
        players_boards = game.players |> Enum.with_index |> Map.new
        %Diggers.DisablingPhaseStarted{game_id: game.game_id, players_boards: players_boards}
    end
  end
end
