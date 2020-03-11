defmodule Diggers.GameEnded do
  @derive Jason.Encoder
  defstruct [:game_id, :winners]


  def apply(game, _event) do
    %Diggers.Game{game | phase: "results" }
  end
end
