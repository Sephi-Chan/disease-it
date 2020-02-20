defmodule Diggers.PlayerJoinsLobby do
  defstruct [:game_id, :player_id]


  def execute(game, command) do
    cond do
      Diggers.Game.has_player?(game, command.player_id) ->
        {:error, :player_already_joined}

      Diggers.Game.players_count(game) == 4 ->
        {:error, :no_more_player_allowed}

      true ->
        %Diggers.PlayerJoinedLobby{game_id: command.game_id, player_id: command.player_id}
    end
  end
end
