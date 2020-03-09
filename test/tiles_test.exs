defmodule TilesTest do
  use ExUnit.Case

  test "build the board from Diggers" do
    Diggers.Board.diggers
  end


  test "build a board for Disease it" do
    Diggers.Board.disease_it
  end


  test "find neighbours when X is even" do
    neighbours = Diggers.Board.neighbours_of(Diggers.Board.diggers, {4, 4})
    assert Enum.member?(neighbours, {5, 5})
    assert Enum.member?(neighbours, {5, 4})
    assert Enum.member?(neighbours, {4, 3})
    assert Enum.member?(neighbours, {3, 3})
    assert Enum.member?(neighbours, {3, 4})
    assert Enum.member?(neighbours, {4, 5})
  end


  test "find neighbours when X is odd" do
    neighbours = Diggers.Board.neighbours_of(Diggers.Board.diggers, {5, 4})
    assert Enum.member?(neighbours, {6, 5})
    assert Enum.member?(neighbours, {6, 4})
    assert Enum.member?(neighbours, {5, 3})
    assert Enum.member?(neighbours, {4, 3})
    assert Enum.member?(neighbours, {4, 4})
    assert Enum.member?(neighbours, {5, 5})
  end


  test "find neighbours when Y is odd" do
    neighbours = Diggers.Board.neighbours_of(Diggers.Board.diggers, {4, 5})
    assert Enum.member?(neighbours, {3, 4})
    assert Enum.member?(neighbours, {4, 4})
    assert Enum.member?(neighbours, {5, 5})
    assert Enum.member?(neighbours, {5, 6})
    assert Enum.member?(neighbours, {4, 6})
    assert Enum.member?(neighbours, {3, 5})
  end


  test "reject offboard neighbours" do
    neighbours = Diggers.Board.neighbours_of(Diggers.Board.diggers, {3, 0})
    assert Enum.member?(neighbours, {4, 1})
    assert Enum.member?(neighbours, {2, 0})
    assert Enum.member?(neighbours, {3, 1})
    assert Enum.count(neighbours) == 3
  end



  test "board boundaries" do
    refute Diggers.Board.on_board?(Diggers.Board.diggers, {-1, 1})
    assert Diggers.Board.on_board?(Diggers.Board.diggers, {0, 1})
    assert Diggers.Board.on_board?(Diggers.Board.diggers, {1, 1})
    assert Diggers.Board.on_board?(Diggers.Board.diggers, {2, 1})
    assert Diggers.Board.on_board?(Diggers.Board.diggers, {3, 1})
    assert Diggers.Board.on_board?(Diggers.Board.diggers, {4, 1})
    refute Diggers.Board.on_board?(Diggers.Board.diggers, {5, 1})
  end
end
