defmodule Diggers.PlayerSuffocated do
  @derive Jason.Encoder
  defstruct [:game_id, :player_id]


  def apply(game, event) do
    %Diggers.Game{game |
      actions_this_round: Map.put(game.actions_this_round, event.player_id, "suffocation"),
      lifes: update_in(game.lifes, [event.player_id], fn (count) -> max(count - 1, 0) end)
    }
  end
end
