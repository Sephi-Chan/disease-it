defmodule Diggers.PlayerLeftLobby do
  @derive Jason.Encoder
  defstruct [:game_id, :player_id]


  def apply(game, event) do
    %Diggers.Game{game | players: Enum.reject(game.players, fn (player_id) -> player_id == event.player_id end)}
  end
end
