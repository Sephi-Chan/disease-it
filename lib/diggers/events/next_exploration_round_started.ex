defmodule Diggers.NextExplorationRoundStarted do
  @derive Jason.Encoder
  defstruct [:game_id]


  def apply(game, _event) do
    %Diggers.Game{game |
      dices_rolls: nil,
      round: game.round + 1
    }
  end
end
