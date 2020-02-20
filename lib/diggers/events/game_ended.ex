defmodule Diggers.GameEnded do
  @derive Jason.Encoder
  defstruct [:game_id, :dices_rolls]


  def apply(game, _event) do
    %Diggers.Game{game | phase: "results" }
  end
end
