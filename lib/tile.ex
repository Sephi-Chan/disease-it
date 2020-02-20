defmodule Diggers.Tile do
  @diamond_tiles %{
    {0, 3} => true,
    {4, 2} => true,
    {3, 5} => true,
    {6, 5} => true,
    {9, 6} => true,
    {7, 9} => true
  }

  @tiles %{
    {9, 9} => [2, 3, 4, 5, 6],
    {9, 8} => [2, 6],
    {9, 7} => [5],
    {9, 6} => [3], # diamond

    {8, 9} => [4, 6],
    {8, 8} => [1, 3],
    {8, 7} => [4],
    {8, 6} => [1],
    {8, 5} => [6],

    {7, 9} => [3], # diamond
    {7, 8} => [5],
    {7, 7} => [6],
    {7, 6} => [2],
    {7, 5} => [4],
    {7, 4} => [3],

    {6, 9} => [1],
    {6, 8} => [2],
    {6, 7} => [4],
    {6, 6} => [5],
    {6, 5} => [3], # diamond
    {6, 4} => [5],
    {6, 3} => [1],

    {5, 8} => [5],
    {5, 7} => [3],
    {5, 6} => [1],
    {5, 5} => [2],
    {5, 4} => [6],
    {5, 3} => [2],
    {5, 2} => [4],

    {4, 7} => [2],
    {4, 6} => [6],
    {4, 5} => [4],
    {4, 4} => [1],
    {4, 3} => [4],
    {4, 2} => [3], # diamond
    {4, 1} => [5],

    {3, 6} => [5],
    {3, 5} => [3], # diamond
    {3, 4} => [6],
    {3, 3} => [5],
    {3, 2} => [2],
    {3, 1} => [1],
    {3, 0} => [3],

    {2, 5} => [1],
    {2, 4} => [2],
    {2, 3} => [3],
    {2, 2} => [4],
    {2, 1} => [5],
    {2, 0} => [6],

    {1, 4} => [4],
    {1, 3} => [5],
    {1, 2} => [1],
    {1, 1} => [3, 6],
    {1, 0} => [1, 5],

    {0, 3} => [3], # diamond
    {0, 2} => [6],
    {0, 1} => [2, 4],
    {0, 0} => [0], # start
  }

  # From "1_1" to {1, 1}.
  def parse(tile_as_string) do
    String.split(tile_as_string, "_")
      |> Enum.map(&String.to_integer/1)
      |> List.to_tuple
  end


  def start?(tile) do
    tile == start_tile()
  end


  def exit?(tile) do
    tile == exit_tile()
  end


  def diamond?(tile) do
    Map.has_key?(@diamond_tiles, tile)
  end


  def tiles do
    @tiles
  end


  def neighbours_of({x, y}) do
    [
      {x + 1, y + 1},
      {x + 1, y},
      {x, y - 1},
      {x - 1, y - 1},
      {x - 1, y},
      {x, y + 1}
    ] |> Enum.filter(&on_board?/1)
  end


  def on_board?({x, y}) do
    0 <= x and x <= 9 and
    0 <= y and y <= 9 and
    abs(x - y) <= 3
  end


  def start_tile do
    {0, 0}
  end


  def exit_tile do
    {9, 9}
  end


  def blank_disabled_tiles(players) do
    player_indexes = 0..(Enum.count(players) - 1)
    Enum.reduce(player_indexes, %{}, fn (index, disabled_tiles) -> Map.put(disabled_tiles, index, []) end)
  end
end
