defmodule Diggers.Tile do
  # From "1_1" to {1, 1}.
  def parse(tile_as_string) do
    String.split(tile_as_string, "_")
      |> Enum.map(&String.to_integer/1)
      |> List.to_tuple
  end


  def blank_disabled_tiles(players) do
    player_indexes = 0..(Enum.count(players) - 1)
    Enum.reduce(player_indexes, %{}, fn (index, disabled_tiles) -> Map.put(disabled_tiles, index, []) end)
  end
end
