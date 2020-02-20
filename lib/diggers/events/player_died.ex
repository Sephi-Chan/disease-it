defmodule Diggers.PlayerDied do
  @derive Jason.Encoder
  defstruct [:game_id, :player_id]


  def apply(game, _event) do
    game
  end
end
