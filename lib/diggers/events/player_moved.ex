defmodule Diggers.PlayerMoved do
  @derive Jason.Encoder
  defstruct [:game_id, :player_id, :tile]


  def apply(game, event) do
    tile = Diggers.Tile.parse(event.tile)

    game
      |> save_action_for_this_round(event.player_id, tile)
      |> add_tile_to_path(event.player_id, tile)
  end


  defp save_action_for_this_round(game, player_id, tile) do
    %Diggers.Game{game | actions_this_round: Map.put(game.actions_this_round, player_id, tile)}
  end


  defp add_tile_to_path(game, player_id, tile) do
    player_index = Diggers.Game.index_of_player(game, player_id)
    %Diggers.Game{game | paths: List.update_at(game.paths, player_index, fn (path) -> [tile|path] end)}
  end
end
