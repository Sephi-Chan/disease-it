defmodule Diggers.LobbyOpened do
  @derive Jason.Encoder
  defstruct [:game_id, :player_id]


  def apply(_game, event) do
    %Diggers.Game{game_id: event.game_id, phase: "lobby", players: [event.player_id]}
  end
end
