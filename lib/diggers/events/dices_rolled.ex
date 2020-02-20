defmodule Diggers.DicesRolled do
  @derive Jason.Encoder
  defstruct [:game_id, :dices_rolls]


  def apply(game, event) do
    %Diggers.Game{game |
      actions_this_round: blank_actions_for_round(game),
      dices_rolls: event.dices_rolls
    }
  end


  defp blank_actions_for_round(game) do
    Enum.reduce(game.players, [], fn (player_id, memo) ->
      List.insert_at(memo, -1, if Diggers.Game.player_died?(game, player_id) do "dead" else nil end)
    end)
  end
end
