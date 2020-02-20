defmodule Diggers.PlayerStartsGame do
  defstruct [:game_id, :player_id]

  def execute(game, command) do
    cond do
      Diggers.Game.owner(game) != command.player_id ->
        {:error, :not_allowed}
      
      not Diggers.Game.lobby_phase?(game) ->
        {:error, :not_allowed_now}
          
      Diggers.Game.players_count(game) < 2 ->
        {:error, :not_enough_players}
        
      true ->
        %Diggers.DisablingPhaseStarted{game_id: game.game_id}
    end
  end
end
