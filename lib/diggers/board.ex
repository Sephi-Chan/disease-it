defmodule Diggers.Board do
  def new() do
    %{
      "tiles" => %{},
      "diamonds" => %{},
      "start_tile" => nil,
      "exit_tile" => nil
    }
  end


  def add_tile(board, {x, y}, terrain, accepted_rolls) do
    put_in(board, ["tiles", "#{x}_#{y}"], %{
      "x" => x,
      "y" => y,
      "terrain" => terrain,
      "accepted_rolls" => accepted_rolls
    })
  end


  def add_diamond(board, {x, y}, type) do
    put_in(board, ["diamonds", "#{x}_#{y}"], %{
      "x" => x,
      "y" => y,
      "type" => type
    })
  end


  def start_at(board, {x, y}) do
    put_in(board["start_tile"], "#{x}_#{y}")
  end


  def exit_at(board, {x, y}) do
    put_in(board["exit_tile"], "#{x}_#{y}")
  end


  def diamond?(board, {x, y}) do
    Map.has_key?(board["diamonds"], "#{x}_#{y}")
  end


  def accepted_rolls(board, {x, y}) do
    board["tiles"]["#{x}_#{y}"]["accepted_rolls"]
  end


  def neighbours_of(board, {x, y}) do
    [
      {x + 1, y + 1},
      {x + 1, y},
      {x, y - 1},
      {x - 1, y - 1},
      {x - 1, y},
      {x, y + 1}
    ] |> Enum.filter(&on_board?(board, &1))
  end


  def on_board?(board, {x, y}) do
    Map.has_key?(board["tiles"], "#{x}_#{y}")
  end


  def start_tile(board) do
    Diggers.Tile.parse(board["start_tile"])
  end


  def exit_tile(board) do
    Diggers.Tile.parse(board["exit_tile"])
  end


  def special_tile?(board, tile) do
    start_tile(board) == tile or exit_tile(board) == tile or diamond?(board, tile)
  end


  def diggers do
    new()
      |> add_tile({9, 9}, "plain", [2, 3, 4, 5, 6]) # exit
      |> add_tile({9, 8}, "plain", [2, 6])
      |> add_tile({9, 7}, "plain", [5])
      |> add_tile({9, 6}, "plain", [3]) # diamond

      |> add_tile({8, 9}, "plain", [4, 6])
      |> add_tile({8, 8}, "plain", [1, 3])
      |> add_tile({8, 7}, "plain", [4])
      |> add_tile({8, 6}, "plain", [1])
      |> add_tile({8, 5}, "plain", [6])

      |> add_tile({7, 9}, "plain", [3]) # diamond
      |> add_tile({7, 8}, "plain", [5])
      |> add_tile({7, 7}, "plain", [6])
      |> add_tile({7, 6}, "plain", [2])
      |> add_tile({7, 5}, "plain", [4])
      |> add_tile({7, 4}, "plain", [3])

      |> add_tile({6, 9}, "plain", [1])
      |> add_tile({6, 8}, "plain", [2])
      |> add_tile({6, 7}, "plain", [4])
      |> add_tile({6, 6}, "plain", [5])
      |> add_tile({6, 5}, "plain", [3]) # diamond
      |> add_tile({6, 4}, "plain", [5])
      |> add_tile({6, 3}, "plain", [1])

      |> add_tile({5, 8}, "plain", [5])
      |> add_tile({5, 7}, "plain", [3])
      |> add_tile({5, 6}, "plain", [1])
      |> add_tile({5, 5}, "plain", [2])
      |> add_tile({5, 4}, "plain", [6])
      |> add_tile({5, 3}, "plain", [2])
      |> add_tile({5, 2}, "plain", [4])

      |> add_tile({4, 7}, "plain", [2])
      |> add_tile({4, 6}, "plain", [6])
      |> add_tile({4, 5}, "plain", [4])
      |> add_tile({4, 4}, "plain", [1])
      |> add_tile({4, 3}, "plain", [4])
      |> add_tile({4, 2}, "plain", [3]) # diamond
      |> add_tile({4, 1}, "plain", [5])

      |> add_tile({3, 6}, "plain", [5])
      |> add_tile({3, 5}, "plain", [3]) # diamond
      |> add_tile({3, 4}, "plain", [6])
      |> add_tile({3, 3}, "plain", [5])
      |> add_tile({3, 2}, "plain", [2])
      |> add_tile({3, 1}, "plain", [1])
      |> add_tile({3, 0}, "plain", [3])

      |> add_tile({2, 5}, "plain", [1])
      |> add_tile({2, 4}, "plain", [2])
      |> add_tile({2, 3}, "plain", [3])
      |> add_tile({2, 2}, "plain", [4])
      |> add_tile({2, 1}, "plain", [5])
      |> add_tile({2, 0}, "plain", [6])

      |> add_tile({1, 4}, "plain", [4])
      |> add_tile({1, 3}, "plain", [5])
      |> add_tile({1, 2}, "plain", [1])
      |> add_tile({1, 1}, "plain", [3, 6])
      |> add_tile({1, 0}, "plain", [1, 5])

      |> add_tile({0, 3}, "plain", [3]) # diamond
      |> add_tile({0, 2}, "plain", [6])
      |> add_tile({0, 1}, "plain", [2, 4])
      |> add_tile({0, 0}, "plain", [0]) # start

      |> add_diamond({0, 3}, "diamond")
      |> add_diamond({4, 2}, "diamond")
      |> add_diamond({3, 5}, "diamond")
      |> add_diamond({6, 5}, "diamond")
      |> add_diamond({9, 6}, "diamond")
      |> add_diamond({7, 9}, "diamond")

      |> start_at({0, 0})
      |> exit_at({9, 9})
  end


  def disease_it do
    new()
      |> add_tile({3,  2},  "forest_11",    [1])
      |> add_tile({3,  1},  "grassland_1",  [6])
      |> add_tile({2,  1},  "mountain_12",  [5])
      |> add_tile({2,  2},  "grassland_1",  [3])
      |> add_tile({-2, -3}, "grassland_1",  [1])
      |> add_tile({-4, -3}, "mountain_9",   [6])
      |> add_tile({-4, -2}, "forest_16",    [2])
      |> add_tile({-4, -1}, "grassland_16", [1])
      |> add_tile({-3, -3}, "forest_17",    [4])
      |> add_tile({0,  -2}, "forest_17",    [6])
      |> add_tile({-2, -2}, "grassland_16", [6])
      |> add_tile({-1, -2}, "forest_11",    [2])
      |> add_tile({-3, -1}, "forest_19",    [3])
      |> add_tile({-2, -1}, "mountain_2",   [4])
      |> add_tile({-1, -1}, "mountain_5",   [5])
      |> add_tile({0,  -1}, "forest_11",    [4])
      |> add_tile({1,  -1}, "grassland_4",  [1])
      |> add_tile({1,  0},  "grassland_4",  [5])
      |> add_tile({-2, 0},  "forest_11",    [4])
      |> add_tile({-1, 0},  "grassland_1",  [4])
      |> add_tile({0,  0},  "forest_11",    [5])
      |> add_tile({-3, -2}, "grassland_10", [5])
      |> add_tile({-2, 1},  "grassland_10", [2])
      |> add_tile({-1, 1},  "grassland_19", [5])
      |> add_tile({0,  1},  "grassland_10", [2])
      |> add_tile({1,  1},  "grassland_16", [3])
      |> add_tile({2,  0},  "grassland_14", [4])
      |> add_tile({2,  -1}, "forest_16",    [3])
      |> add_tile({-1, -3}, "grassland_16", [2])
      |> add_tile({-3, -4}, "grassland_1",  [3])
      |> add_tile({-2, -4}, "mountain_6",   [6])
      |> add_tile({-1, -4}, "grassland_14", [1])
      |> add_tile({1,  -2}, "grassland_16", [3])

      |> add_diamond({2, 2}, "tower")
      |> add_diamond({-2, -3}, "church")
      |> add_diamond({3, 1}, "castle")
      |> add_diamond({1, -1}, "tents")
      |> add_diamond({0, 1}, "city")
      |> add_diamond({-2, -2}, "fortified_city")
      |> add_diamond({-2, 1}, "mill")

      |> start_at({-4, -1})
      |> exit_at({3, 1})
  end
end
