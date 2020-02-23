defmodule Diggers.LobbyClosed do
  @derive Jason.Encoder
  defstruct [:game_id]


  def apply(_game, _event) do
    %Diggers.Game{}
  end
end
