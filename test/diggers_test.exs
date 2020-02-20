defmodule DiggersTest do
  use Diggers.DatabaseCase


  test "Can't open a lobby twice" do
    :ok = Diggers.Application.dispatch(%Diggers.PlayerOpensLobby{game_id: "game_1", player_id: "Corwin"})
    {:error, :player_already_joined} = Diggers.Application.dispatch(%Diggers.PlayerOpensLobby{game_id: "game_1", player_id: "Corwin"})
  end


  test "Can't join a lobby twice" do
    :ok = Diggers.Application.dispatch(%Diggers.PlayerOpensLobby{game_id: "game_1", player_id: "Corwin"})
    {:error, :player_already_joined} = Diggers.Application.dispatch(%Diggers.PlayerJoinsLobby{game_id: "game_1", player_id: "Corwin"})
    :ok = Diggers.Application.dispatch(%Diggers.PlayerJoinsLobby{game_id: "game_1", player_id: "Mandor"})
    {:error, :player_already_joined} = Diggers.Application.dispatch(%Diggers.PlayerJoinsLobby{game_id: "game_1", player_id: "Mandor"})
  end


  test "The game is limited to 4 players" do
    :ok = Diggers.Application.dispatch(%Diggers.PlayerOpensLobby{game_id: "game_1", player_id: "Corwin"})
    :ok = Diggers.Application.dispatch(%Diggers.PlayerJoinsLobby{game_id: "game_1", player_id: "Mandor"})
    :ok = Diggers.Application.dispatch(%Diggers.PlayerJoinsLobby{game_id: "game_1", player_id: "Eric"})
    :ok = Diggers.Application.dispatch(%Diggers.PlayerJoinsLobby{game_id: "game_1", player_id: "Random"})
    {:error, :no_more_player_allowed} = Diggers.Application.dispatch(%Diggers.PlayerJoinsLobby{game_id: "game_1", player_id: "Brand"})
    :ok = Diggers.Application.dispatch(%Diggers.PlayerLeavesLobby{game_id: "game_1", player_id: "Corwin"})
    :ok = Diggers.Application.dispatch(%Diggers.PlayerJoinsLobby{game_id: "game_1", player_id: "Brand"})
    {:error, :no_more_player_allowed} = Diggers.Application.dispatch(%Diggers.PlayerJoinsLobby{game_id: "game_1", player_id: "Fiona"})
  end


  test "A player can only leave a lobby if he joined it" do
    :ok = Diggers.Application.dispatch(%Diggers.PlayerOpensLobby{game_id: "game_1", player_id: "Corwin"})
    {:error, :player_not_found} = Diggers.Application.dispatch(%Diggers.PlayerLeavesLobby{game_id: "game_1", player_id: "Mandor"})
    :ok = Diggers.Application.dispatch(%Diggers.PlayerLeavesLobby{game_id: "game_1", player_id: "Corwin"})
    :ok = Diggers.Application.dispatch(%Diggers.PlayerJoinsLobby{game_id: "game_1", player_id: "Corwin"})
  end


  test "Only the creator can start the game" do
    :ok = Diggers.Application.dispatch(%Diggers.PlayerOpensLobby{game_id: "game_1", player_id: "Corwin"})
    :ok = Diggers.Application.dispatch(%Diggers.PlayerJoinsLobby{game_id: "game_1", player_id: "Mandor"})
    {:error, :not_allowed} = Diggers.Application.dispatch(%Diggers.PlayerStartsGame{game_id: "game_1", player_id: "Mandor"})
  end


  test "Creator can only start a game with at least 2 players" do
    :ok = Diggers.Application.dispatch(%Diggers.PlayerOpensLobby{game_id: "game_1", player_id: "Corwin"})
    {:error, :not_enough_players} = Diggers.Application.dispatch(%Diggers.PlayerStartsGame{game_id: "game_1", player_id: "Corwin"})
  end


  test "A player can't disable a tile until the game is started" do
    :ok = Diggers.Application.dispatch(%Diggers.PlayerOpensLobby{game_id: "game_1", player_id: "Corwin"})
    :ok = Diggers.Application.dispatch(%Diggers.PlayerJoinsLobby{game_id: "game_1", player_id: "Mandor"})
    {:error, :not_allowed_now} = Diggers.Application.dispatch(%Diggers.PlayerDisablesTile{game_id: "game_1", player_id: "Corwin", tile: "1_1"})
  end


  test "An unknown player can't disable a tile" do
    :ok = Diggers.Application.dispatch(%Diggers.PlayerOpensLobby{game_id: "game_1", player_id: "Corwin"})
    :ok = Diggers.Application.dispatch(%Diggers.PlayerJoinsLobby{game_id: "game_1", player_id: "Mandor"})
    :ok = Diggers.Application.dispatch(%Diggers.PlayerStartsGame{game_id: "game_1", player_id: "Corwin"})
    {:error, :player_not_found} = Diggers.Application.dispatch(%Diggers.PlayerDisablesTile{game_id: "game_1", player_id: "Eric", tile: "1_1"})
  end


  test "A player can't disable a tile that is out of board" do
    :ok = Diggers.Application.dispatch(%Diggers.PlayerOpensLobby{game_id: "game_1", player_id: "Corwin"})
    :ok = Diggers.Application.dispatch(%Diggers.PlayerJoinsLobby{game_id: "game_1", player_id: "Mandor"})
    :ok = Diggers.Application.dispatch(%Diggers.PlayerStartsGame{game_id: "game_1", player_id: "Corwin"})
    {:error, :tile_not_found} = Diggers.Application.dispatch(%Diggers.PlayerDisablesTile{game_id: "game_1", player_id: "Corwin", tile: "10_10"})
  end


  test "A player can't disable tiles start, exit nor diamond tiles" do
    :ok = Diggers.Application.dispatch(%Diggers.PlayerOpensLobby{game_id: "game_1", player_id: "Corwin"})
    :ok = Diggers.Application.dispatch(%Diggers.PlayerJoinsLobby{game_id: "game_1", player_id: "Mandor"})
    :ok = Diggers.Application.dispatch(%Diggers.PlayerStartsGame{game_id: "game_1", player_id: "Corwin"})
    {:error, :not_allowed_on_special_tiles} = Diggers.Application.dispatch(%Diggers.PlayerDisablesTile{game_id: "game_1", player_id: "Corwin", tile: "3_5"})
    {:error, :not_allowed_on_special_tiles} = Diggers.Application.dispatch(%Diggers.PlayerDisablesTile{game_id: "game_1", player_id: "Corwin", tile: "9_9"})
    {:error, :not_allowed_on_special_tiles} = Diggers.Application.dispatch(%Diggers.PlayerDisablesTile{game_id: "game_1", player_id: "Corwin", tile: "0_0"})
  end


  test "A player can't disable a tile twice" do
    :ok = Diggers.Application.dispatch(%Diggers.PlayerOpensLobby{game_id: "game_1", player_id: "Corwin"})
    :ok = Diggers.Application.dispatch(%Diggers.PlayerJoinsLobby{game_id: "game_1", player_id: "Mandor"})
    :ok = Diggers.Application.dispatch(%Diggers.PlayerStartsGame{game_id: "game_1", player_id: "Corwin"})
    :ok = Diggers.Application.dispatch(%Diggers.PlayerDisablesTile{game_id: "game_1", player_id: "Corwin", tile: "1_2"})
    {:error, :already_disabled} = Diggers.Application.dispatch(%Diggers.PlayerDisablesTile{game_id: "game_1", player_id: "Corwin", tile: "1_2"})
  end


  test "A player can't disable a tile adjacent to a disabled tile" do
    :ok = Diggers.Application.dispatch(%Diggers.PlayerOpensLobby{game_id: "game_1", player_id: "Corwin"})
    :ok = Diggers.Application.dispatch(%Diggers.PlayerJoinsLobby{game_id: "game_1", player_id: "Mandor"})
    :ok = Diggers.Application.dispatch(%Diggers.PlayerStartsGame{game_id: "game_1", player_id: "Corwin"})
    :ok = Diggers.Application.dispatch(%Diggers.PlayerDisablesTile{game_id: "game_1", player_id: "Corwin", tile: "1_2"})
    {:error, :neighbour_already_disabled} = Diggers.Application.dispatch(%Diggers.PlayerDisablesTile{game_id: "game_1", player_id: "Corwin", tile: "2_2"})
  end


  test "A player can't disable more than three tiles on the board" do
    :ok = Diggers.Application.dispatch(%Diggers.PlayerOpensLobby{game_id: "game_1", player_id: "Corwin"})
    :ok = Diggers.Application.dispatch(%Diggers.PlayerJoinsLobby{game_id: "game_1", player_id: "Mandor"})
    :ok = Diggers.Application.dispatch(%Diggers.PlayerStartsGame{game_id: "game_1", player_id: "Corwin"})
    :ok = Diggers.Application.dispatch(%Diggers.PlayerDisablesTile{game_id: "game_1", player_id: "Corwin", tile: "1_4"})
    :ok = Diggers.Application.dispatch(%Diggers.PlayerDisablesTile{game_id: "game_1", player_id: "Corwin", tile: "1_2"})
    :ok = Diggers.Application.dispatch(%Diggers.PlayerDisablesTile{game_id: "game_1", player_id: "Corwin", tile: "1_0"})
    {:error, :no_more_disabling_allowed} = Diggers.Application.dispatch(%Diggers.PlayerDisablesTile{game_id: "game_1", player_id: "Corwin", tile: "3_1"})
  end


  test "A simple game" do
    :ok = Diggers.Application.dispatch(%Diggers.PlayerOpensLobby{game_id: "game_1", player_id: "Corwin"})
    :ok = Diggers.Application.dispatch(%Diggers.PlayerJoinsLobby{game_id: "game_1", player_id: "Mandor"})
    :ok = Diggers.Application.dispatch(%Diggers.PlayerStartsGame{game_id: "game_1", player_id: "Corwin"})

    :ok = Diggers.Application.dispatch(%Diggers.PlayerDisablesTile{game_id: "game_1", player_id: "Corwin", tile: "1_3"})
    :ok = Diggers.Application.dispatch(%Diggers.PlayerDisablesTile{game_id: "game_1", player_id: "Corwin", tile: "0_1"})
    :ok = Diggers.Application.dispatch(%Diggers.PlayerDisablesTile{game_id: "game_1", player_id: "Corwin", tile: "3_4"})
    :ok = Diggers.Application.dispatch(%Diggers.PlayerDisablesTile{game_id: "game_1", player_id: "Mandor", tile: "1_0"})
    :ok = Diggers.Application.dispatch(%Diggers.PlayerDisablesTile{game_id: "game_1", player_id: "Mandor", tile: "3_2"})
    :ok = Diggers.Application.dispatch(%Diggers.PlayerDisablesTile{game_id: "game_1", player_id: "Mandor", tile: "5_4"})

    :ok = Diggers.Application.dispatch(%Diggers.PlayerDisablesTile{game_id: "game_1", player_id: "Corwin", tile: "2_3"})
    :ok = Diggers.Application.dispatch(%Diggers.PlayerDisablesTile{game_id: "game_1", player_id: "Corwin", tile: "0_1"})
    :ok = Diggers.Application.dispatch(%Diggers.PlayerDisablesTile{game_id: "game_1", player_id: "Corwin", tile: "3_0"})
    :ok = Diggers.Application.dispatch(%Diggers.PlayerDisablesTile{game_id: "game_1", player_id: "Mandor", tile: "8_8"})
    :ok = Diggers.Application.dispatch(%Diggers.PlayerDisablesTile{game_id: "game_1", player_id: "Mandor", tile: "2_2"})
    :ok = Diggers.Application.dispatch(%Diggers.PlayerDisablesTile{game_id: "game_1", player_id: "Mandor", tile: "4_3"})

    {:error, :not_allowed_now} = Diggers.Application.dispatch(%Diggers.PlayerStartsGame{game_id: "game_1", player_id: "Corwin"})
    {:error, :not_allowed_now} = Diggers.Application.dispatch(%Diggers.PlayerDisablesTile{game_id: "game_1", player_id: "Corwin", tile: "1_2"})

    :ok = Diggers.Application.dispatch(%Diggers.PlayerRollsDices{game_id: "game_1", dices_rolls: [1, 2, 2, 1]})
    {:error, :dices_already_rolled} = Diggers.Application.dispatch(%Diggers.PlayerRollsDices{game_id: "game_1", dices_rolls: [1, 2, 2, 1]})

    {:error, :player_not_found} = Diggers.Application.dispatch(%Diggers.PlayerMoves{game_id: "game_1", player_id: "Eric", tile: "1_1"})
    {:error, :suffocated_this_round} = Diggers.Application.dispatch(%Diggers.PlayerMoves{game_id: "game_1", player_id: "Mandor", tile: "1_1"})
    {:error, :tile_not_in_neighbours} = Diggers.Application.dispatch(%Diggers.PlayerMoves{game_id: "game_1", player_id: "Corwin", tile: "9_9"})
    {:error, :tile_is_disabled} = Diggers.Application.dispatch(%Diggers.PlayerMoves{game_id: "game_1", player_id: "Corwin", tile: "0_1"})
    {:error, :tile_is_unavailable} = Diggers.Application.dispatch(%Diggers.PlayerMoves{game_id: "game_1", player_id: "Corwin", tile: "1_1"})
    :ok = Diggers.Application.dispatch(%Diggers.PlayerMoves{game_id: "game_1", player_id: "Corwin", tile: "1_0"})

    :ok = Diggers.Application.dispatch(%Diggers.PlayerRollsDices{game_id: "game_1", dices_rolls: [3, 3, 5, 6]})
    :ok = Diggers.Application.dispatch(%Diggers.PlayerMoves{game_id: "game_1", player_id: "Corwin", tile: "2_1"})
    {:error, :already_moved_this_round} = Diggers.Application.dispatch(%Diggers.PlayerMoves{game_id: "game_1", player_id: "Corwin", tile: "2_1"})
    :ok = Diggers.Application.dispatch(%Diggers.PlayerMoves{game_id: "game_1", player_id: "Mandor", tile: "1_1"})

    :ok = Diggers.Application.dispatch(%Diggers.PlayerRollsDices{game_id: "game_1", dices_rolls: [3, 4, 5, 2]})
    :ok = Diggers.Application.dispatch(%Diggers.PlayerMoves{game_id: "game_1", player_id: "Mandor", tile: "2_2"})
    :ok = Diggers.Application.dispatch(%Diggers.PlayerMoves{game_id: "game_1", player_id: "Corwin", tile: "3_2"})

    :ok = Diggers.Application.dispatch(%Diggers.PlayerRollsDices{game_id: "game_1", dices_rolls: [3, 4, 5, 6]})
    :ok = Diggers.Application.dispatch(%Diggers.PlayerMoves{game_id: "game_1", player_id: "Corwin", tile: "4_2"})
    :ok = Diggers.Application.dispatch(%Diggers.PlayerMoves{game_id: "game_1", player_id: "Mandor", tile: "3_3"})

    :ok = Diggers.Application.dispatch(%Diggers.PlayerRollsDices{game_id: "game_1", dices_rolls: [1, 2, 4, 5]})
    :ok = Diggers.Application.dispatch(%Diggers.PlayerMoves{game_id: "game_1", player_id: "Corwin", tile: "5_3"})
    :ok = Diggers.Application.dispatch(%Diggers.PlayerMoves{game_id: "game_1", player_id: "Mandor", tile: "4_4"})

    :ok = Diggers.Application.dispatch(%Diggers.PlayerRollsDices{game_id: "game_1", dices_rolls: [1, 2, 4, 5]})
    :ok = Diggers.Application.dispatch(%Diggers.PlayerMoves{game_id: "game_1", player_id: "Corwin", tile: "6_4"})
    :ok = Diggers.Application.dispatch(%Diggers.PlayerMoves{game_id: "game_1", player_id: "Mandor", tile: "5_5"})

    :ok = Diggers.Application.dispatch(%Diggers.PlayerRollsDices{game_id: "game_1", dices_rolls: [3, 3, 3, 3]})
    :ok = Diggers.Application.dispatch(%Diggers.PlayerMoves{game_id: "game_1", player_id: "Corwin", tile: "6_5"})
    :ok = Diggers.Application.dispatch(%Diggers.PlayerMoves{game_id: "game_1", player_id: "Mandor", tile: "6_5"})

    :ok = Diggers.Application.dispatch(%Diggers.PlayerRollsDices{game_id: "game_1", dices_rolls: [2, 2, 2, 2]})
    :ok = Diggers.Application.dispatch(%Diggers.PlayerMoves{game_id: "game_1", player_id: "Corwin", tile: "7_6"})
    :ok = Diggers.Application.dispatch(%Diggers.PlayerMoves{game_id: "game_1", player_id: "Mandor", tile: "7_6"})

    :ok = Diggers.Application.dispatch(%Diggers.PlayerRollsDices{game_id: "game_1", dices_rolls: [4, 4, 4, 4]})
    :ok = Diggers.Application.dispatch(%Diggers.PlayerMoves{game_id: "game_1", player_id: "Corwin", tile: "8_7"})
    :ok = Diggers.Application.dispatch(%Diggers.PlayerMoves{game_id: "game_1", player_id: "Mandor", tile: "8_7"})

    :ok = Diggers.Application.dispatch(%Diggers.PlayerRollsDices{game_id: "game_1", dices_rolls: [2, 2, 3, 5]})
    :ok = Diggers.Application.dispatch(%Diggers.PlayerMoves{game_id: "game_1", player_id: "Corwin", tile: "9_8"})
    :ok = Diggers.Application.dispatch(%Diggers.PlayerMoves{game_id: "game_1", player_id: "Mandor", tile: "8_8"})

    :ok = Diggers.Application.dispatch(%Diggers.PlayerRollsDices{game_id: "game_1", dices_rolls: [2, 2, 4, 5]})
    :ok = Diggers.Application.dispatch(%Diggers.PlayerMoves{game_id: "game_1", player_id: "Corwin", tile: "9_9"})
    :ok = Diggers.Application.dispatch(%Diggers.PlayerMoves{game_id: "game_1", player_id: "Mandor", tile: "8_9"})

    {:error, :too_many_dices_rolls} = Diggers.Application.dispatch(%Diggers.PlayerRollsDices{game_id: "game_1", dices_rolls: [2, 2, 4, 5]})
    :ok = Diggers.Application.dispatch(%Diggers.PlayerRollsDices{game_id: "game_1", dices_rolls: [2, 3, 4]})
    {:error, :player_already_left} = Diggers.Application.dispatch(%Diggers.PlayerMoves{game_id: "game_1", player_id: "Corwin", tile: "9_9"})
    :ok = Diggers.Application.dispatch(%Diggers.PlayerMoves{game_id: "game_1", player_id: "Mandor", tile: "9_9"})

    {:error, :not_allowed_now} = Diggers.Application.dispatch(%Diggers.PlayerRollsDices{game_id: "game_1", dices_rolls: [2, 2, 4, 5]})
    {:error, :not_allowed_now} = Diggers.Application.dispatch(%Diggers.PlayerMoves{game_id: "game_1", player_id: "Mandor", tile: "9_9"})

    [{16, "Corwin"}, {8, "Mandor"}] = Diggers.Game.winners(game())
  end


  test "A game where everybody dies" do
    :ok = Diggers.Application.dispatch(%Diggers.PlayerOpensLobby{game_id: "game_1", player_id: "Corwin"})
    :ok = Diggers.Application.dispatch(%Diggers.PlayerJoinsLobby{game_id: "game_1", player_id: "Mandor"})
    :ok = Diggers.Application.dispatch(%Diggers.PlayerStartsGame{game_id: "game_1", player_id: "Corwin"})

    :ok = Diggers.Application.dispatch(%Diggers.PlayerDisablesTile{game_id: "game_1", player_id: "Corwin", tile: "1_3"})
    :ok = Diggers.Application.dispatch(%Diggers.PlayerDisablesTile{game_id: "game_1", player_id: "Corwin", tile: "0_1"})
    :ok = Diggers.Application.dispatch(%Diggers.PlayerDisablesTile{game_id: "game_1", player_id: "Corwin", tile: "3_4"})
    :ok = Diggers.Application.dispatch(%Diggers.PlayerDisablesTile{game_id: "game_1", player_id: "Mandor", tile: "1_0"})
    :ok = Diggers.Application.dispatch(%Diggers.PlayerDisablesTile{game_id: "game_1", player_id: "Mandor", tile: "3_2"})
    :ok = Diggers.Application.dispatch(%Diggers.PlayerDisablesTile{game_id: "game_1", player_id: "Mandor", tile: "5_4"})

    :ok = Diggers.Application.dispatch(%Diggers.PlayerDisablesTile{game_id: "game_1", player_id: "Corwin", tile: "2_3"})
    :ok = Diggers.Application.dispatch(%Diggers.PlayerDisablesTile{game_id: "game_1", player_id: "Corwin", tile: "0_1"})
    :ok = Diggers.Application.dispatch(%Diggers.PlayerDisablesTile{game_id: "game_1", player_id: "Corwin", tile: "3_0"})
    :ok = Diggers.Application.dispatch(%Diggers.PlayerDisablesTile{game_id: "game_1", player_id: "Mandor", tile: "8_8"})
    :ok = Diggers.Application.dispatch(%Diggers.PlayerDisablesTile{game_id: "game_1", player_id: "Mandor", tile: "2_2"})
    :ok = Diggers.Application.dispatch(%Diggers.PlayerDisablesTile{game_id: "game_1", player_id: "Mandor", tile: "4_3"})

    :ok = Diggers.Application.dispatch(%Diggers.PlayerRollsDices{game_id: "game_1", dices_rolls: [2, 2, 2, 2]})
    :ok = Diggers.Application.dispatch(%Diggers.PlayerRollsDices{game_id: "game_1", dices_rolls: [2, 2, 2, 2]})
    :ok = Diggers.Application.dispatch(%Diggers.PlayerRollsDices{game_id: "game_1", dices_rolls: [2, 2, 2, 2]})
    :ok = Diggers.Application.dispatch(%Diggers.PlayerRollsDices{game_id: "game_1", dices_rolls: [2, 2, 2, 5]})
    :ok = Diggers.Application.dispatch(%Diggers.PlayerMoves{game_id: "game_1", player_id: "Corwin", tile: "1_0"})
    :ok = Diggers.Application.dispatch(%Diggers.PlayerRollsDices{game_id: "game_1", dices_rolls: [2, 2, 2, 2]}) # Kill Mandor.
    :ok = Diggers.Application.dispatch(%Diggers.PlayerRollsDices{game_id: "game_1", dices_rolls: [2, 3, 4, 5]})
    :ok = Diggers.Application.dispatch(%Diggers.PlayerMoves{game_id: "game_1", player_id: "Corwin", tile: "2_1"})
    {:error, :player_is_dead} = Diggers.Application.dispatch(%Diggers.PlayerMoves{game_id: "game_1", player_id: "Mandor", tile: "2_1"})
    :ok = Diggers.Application.dispatch(%Diggers.PlayerRollsDices{game_id: "game_1", dices_rolls: [2, 3, 4, 5]})
    :ok = Diggers.Application.dispatch(%Diggers.PlayerMoves{game_id: "game_1", player_id: "Corwin", tile: "3_2"})
    :ok = Diggers.Application.dispatch(%Diggers.PlayerRollsDices{game_id: "game_1", dices_rolls: [2, 2, 2, 2]})

    [] = Diggers.Game.winners(game())
  end


  test "A player dies, the other survives." do
    :ok = Diggers.Application.dispatch(%Diggers.PlayerOpensLobby{game_id: "game_1", player_id: "Corwin"})
    :ok = Diggers.Application.dispatch(%Diggers.PlayerJoinsLobby{game_id: "game_1", player_id: "Mandor"})
    :ok = Diggers.Application.dispatch(%Diggers.PlayerStartsGame{game_id: "game_1", player_id: "Corwin"})

    :ok = Diggers.Application.dispatch(%Diggers.PlayerDisablesTile{game_id: "game_1", player_id: "Corwin", tile: "1_3"})
    :ok = Diggers.Application.dispatch(%Diggers.PlayerDisablesTile{game_id: "game_1", player_id: "Corwin", tile: "0_1"})
    :ok = Diggers.Application.dispatch(%Diggers.PlayerDisablesTile{game_id: "game_1", player_id: "Corwin", tile: "3_4"})
    :ok = Diggers.Application.dispatch(%Diggers.PlayerDisablesTile{game_id: "game_1", player_id: "Mandor", tile: "1_0"})
    :ok = Diggers.Application.dispatch(%Diggers.PlayerDisablesTile{game_id: "game_1", player_id: "Mandor", tile: "3_2"})
    :ok = Diggers.Application.dispatch(%Diggers.PlayerDisablesTile{game_id: "game_1", player_id: "Mandor", tile: "5_4"})

    :ok = Diggers.Application.dispatch(%Diggers.PlayerDisablesTile{game_id: "game_1", player_id: "Corwin", tile: "2_3"})
    :ok = Diggers.Application.dispatch(%Diggers.PlayerDisablesTile{game_id: "game_1", player_id: "Corwin", tile: "0_1"})
    :ok = Diggers.Application.dispatch(%Diggers.PlayerDisablesTile{game_id: "game_1", player_id: "Corwin", tile: "3_0"})
    :ok = Diggers.Application.dispatch(%Diggers.PlayerDisablesTile{game_id: "game_1", player_id: "Mandor", tile: "8_9"})
    :ok = Diggers.Application.dispatch(%Diggers.PlayerDisablesTile{game_id: "game_1", player_id: "Mandor", tile: "2_2"})
    :ok = Diggers.Application.dispatch(%Diggers.PlayerDisablesTile{game_id: "game_1", player_id: "Mandor", tile: "4_3"})

    :ok = Diggers.Application.dispatch(%Diggers.PlayerRollsDices{game_id: "game_1", dices_rolls: [2, 2, 5, 2]})
    :ok = Diggers.Application.dispatch(%Diggers.PlayerMoves{game_id: "game_1", player_id: "Corwin", tile: "1_0"})
    :ok = Diggers.Application.dispatch(%Diggers.PlayerRollsDices{game_id: "game_1", dices_rolls: [2, 2, 5, 2]})
    :ok = Diggers.Application.dispatch(%Diggers.PlayerMoves{game_id: "game_1", player_id: "Corwin", tile: "2_1"})
    :ok = Diggers.Application.dispatch(%Diggers.PlayerRollsDices{game_id: "game_1", dices_rolls: [2, 2, 2, 2]})
    :ok = Diggers.Application.dispatch(%Diggers.PlayerMoves{game_id: "game_1", player_id: "Corwin", tile: "3_2"})
    :ok = Diggers.Application.dispatch(%Diggers.PlayerRollsDices{game_id: "game_1", dices_rolls: [2, 2, 2, 5]})
    :ok = Diggers.Application.dispatch(%Diggers.PlayerMoves{game_id: "game_1", player_id: "Corwin", tile: "3_3"})
    :ok = Diggers.Application.dispatch(%Diggers.PlayerRollsDices{game_id: "game_1", dices_rolls: [1, 1, 1, 1]})
    :ok = Diggers.Application.dispatch(%Diggers.PlayerMoves{game_id: "game_1", player_id: "Corwin", tile: "4_4"})
    :ok = Diggers.Application.dispatch(%Diggers.PlayerRollsDices{game_id: "game_1", dices_rolls: [2, 3, 5, 6]})
    :ok = Diggers.Application.dispatch(%Diggers.PlayerMoves{game_id: "game_1", player_id: "Corwin", tile: "5_5"})
    :ok = Diggers.Application.dispatch(%Diggers.PlayerRollsDices{game_id: "game_1", dices_rolls: [2, 3, 5, 6]})
    :ok = Diggers.Application.dispatch(%Diggers.PlayerMoves{game_id: "game_1", player_id: "Corwin", tile: "6_6"})
    :ok = Diggers.Application.dispatch(%Diggers.PlayerRollsDices{game_id: "game_1", dices_rolls: [2, 3, 5, 6]})
    :ok = Diggers.Application.dispatch(%Diggers.PlayerMoves{game_id: "game_1", player_id: "Corwin", tile: "7_7"})
    :ok = Diggers.Application.dispatch(%Diggers.PlayerRollsDices{game_id: "game_1", dices_rolls: [2, 3, 5, 6]})
    :ok = Diggers.Application.dispatch(%Diggers.PlayerMoves{game_id: "game_1", player_id: "Corwin", tile: "8_8"})
    :ok = Diggers.Application.dispatch(%Diggers.PlayerRollsDices{game_id: "game_1", dices_rolls: [2, 3, 5, 6]})
    :ok = Diggers.Application.dispatch(%Diggers.PlayerMoves{game_id: "game_1", player_id: "Corwin", tile: "9_9"})

    [{10, "Corwin"}] = Diggers.Game.winners(game())
  end

  defp game(game_id \\ "game_1") do
    Commanded.Aggregates.Aggregate.aggregate_state(Diggers.Application, Diggers.Game, game_id)
  end
end
