defmodule Diggers.Tile do
  # From "1_1" to {1, 1}.
  def parse(tile_as_string) do
    String.split(tile_as_string, "_")
      |> Enum.map(&String.to_integer/1)
      |> List.to_tuple
  end


  def dump({x, y}) do
    "#{x}_#{y}"
  end


  def blank_disabled_tiles(players) do
    player_indexes = 0..(Enum.count(players) - 1)
    Enum.reduce(player_indexes, %{}, fn (index, disabled_tiles) -> Map.put(disabled_tiles, index, []) end)
  end


  def tiles_to_disable_for_players_count(2) do 3 end 
  def tiles_to_disable_for_players_count(3) do 2 end 
  def tiles_to_disable_for_players_count(4) do 1 end 
end
