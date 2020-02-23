alias Commanded.Aggregate.Multi


defmodule Diggers.PlayerLeavesLobby do
  defstruct [:game_id, :player_id]


  def execute(game, command) do
    cond do
      not Diggers.Game.has_player?(game, command.player_id) ->
        {:error, :player_not_found}

      not Diggers.Game.lobby_phase?(game) ->
        {:error, :not_allowed_now}

      true ->
        game
          |> Multi.new
          |> Multi.execute(&leave_lobby(&1, command.player_id))
          |> Multi.execute(&try_to_close_lobby/1)
    end
  end


  defp leave_lobby(game, player_id) do
    %Diggers.PlayerLeftLobby{game_id: game.game_id, player_id: player_id}
  end


  defp try_to_close_lobby(game) do
    if Enum.empty?(game.players) do
      %Diggers.LobbyClosed{game_id: game.game_id}
    end
  end
end
