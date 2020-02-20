defmodule TilesTest do
  use ExUnit.Case


  test "find neighbours when X is even" do
    neighbours = Diggers.Tile.neighbours_of({4, 4})
    assert Enum.member?(neighbours, {5, 5})
    assert Enum.member?(neighbours, {5, 4})
    assert Enum.member?(neighbours, {4, 3})
    assert Enum.member?(neighbours, {3, 3})
    assert Enum.member?(neighbours, {3, 4})
    assert Enum.member?(neighbours, {4, 5})
  end


  test "find neighbours when X is odd" do
    neighbours = Diggers.Tile.neighbours_of({5, 4})
    assert Enum.member?(neighbours, {6, 5})
    assert Enum.member?(neighbours, {6, 4})
    assert Enum.member?(neighbours, {5, 3})
    assert Enum.member?(neighbours, {4, 3})
    assert Enum.member?(neighbours, {4, 4})
    assert Enum.member?(neighbours, {5, 5})
  end


  test "find neighbours when Y is odd" do
    neighbours = Diggers.Tile.neighbours_of({4, 5})
    assert Enum.member?(neighbours, {3, 4})
    assert Enum.member?(neighbours, {4, 4})
    assert Enum.member?(neighbours, {5, 5})
    assert Enum.member?(neighbours, {5, 6})
    assert Enum.member?(neighbours, {4, 6})
    assert Enum.member?(neighbours, {3, 5})
  end


  test "reject offboard neighbours" do
    neighbours = Diggers.Tile.neighbours_of({3, 0})
    assert Enum.member?(neighbours, {4, 1})
    assert Enum.member?(neighbours, {2, 0})
    assert Enum.member?(neighbours, {3, 1})
    assert Enum.count(neighbours) == 3
  end



  test "board boundaries" do
    refute Diggers.Tile.on_board?({-1, 1})
    assert Diggers.Tile.on_board?({0, 1})
    assert Diggers.Tile.on_board?({1, 1})
    assert Diggers.Tile.on_board?({2, 1})
    assert Diggers.Tile.on_board?({3, 1})
    assert Diggers.Tile.on_board?({4, 1})
    refute Diggers.Tile.on_board?({5, 1})
  end
end
