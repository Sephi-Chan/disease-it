defmodule Diggers.PlayerOpensLobby do
  defstruct [:game_id, :player_id]


  def execute(%Diggers.Game{game_id: nil}, command) do
    %Diggers.LobbyOpened{game_id: command.game_id, player_id: command.player_id}
  end


  def execute(game, command) do
    cond do
      Diggers.Game.has_player?(game, command.player_id) ->
        {:error, :player_already_joined}

      true ->
        %Diggers.LobbyOpened{game_id: command.game_id, player_id: command.player_id}
    end
  end
end
