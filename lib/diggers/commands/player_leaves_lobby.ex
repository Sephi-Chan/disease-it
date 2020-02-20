defmodule Diggers.PlayerLeavesLobby do
  defstruct [:game_id, :player_id]


  def execute(game, command) do
    cond do
      not Diggers.Game.has_player?(game, command.player_id) ->
        {:error, :player_not_found}

      true ->
        %Diggers.PlayerLeftLobby{game_id: command.game_id, player_id: command.player_id}
    end
  end
end
