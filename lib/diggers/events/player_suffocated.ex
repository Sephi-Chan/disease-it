defmodule Diggers.PlayerSuffocated do
  @derive Jason.Encoder
  defstruct [:game_id, :player_id]


  def apply(game, event) do
    player_index = Diggers.Game.index_of_player(game, event.player_id)
    %Diggers.Game{game |
      actions_this_round: List.replace_at(game.actions_this_round, player_index, "suffocation"),
      lifes: update_in(game.lifes, [event.player_id], fn (count) -> max(count - 1, 0) end)
    }
  end
end
