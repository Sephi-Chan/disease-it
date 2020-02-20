defmodule Diggers.PlayerLeft do
  @derive Jason.Encoder
  defstruct [:game_id, :player_id]


  def apply(game, event) do
    %Diggers.Game{game |
      gone_players: Map.put(game.gone_players, event.player_id, game.round)
    }
  end
end
