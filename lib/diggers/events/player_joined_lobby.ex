defmodule Diggers.PlayerJoinedLobby do
  @derive Jason.Encoder
  defstruct [:game_id, :player_id]


  def apply(game, event) do
    %Diggers.Game{game | players: game.players ++ [event.player_id]}
  end
end
