defmodule DiggersTest do
  use Diggers.DatabaseCase


  test "Can't open a lobby twice" do
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerOpensLobby{game_id: "game_1", player_id: "Corwin"})
    {:error, :player_already_joined} = Diggers.CommandedApplication.dispatch(%Diggers.PlayerOpensLobby{game_id: "game_1", player_id: "Corwin"})
  end


  test "Can't join a lobby twice" do
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerOpensLobby{game_id: "game_1", player_id: "Corwin"})
    {:error, :player_already_joined} = Diggers.CommandedApplication.dispatch(%Diggers.PlayerJoinsLobby{game_id: "game_1", player_id: "Corwin"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerJoinsLobby{game_id: "game_1", player_id: "Mandor"})
    {:error, :player_already_joined} = Diggers.CommandedApplication.dispatch(%Diggers.PlayerJoinsLobby{game_id: "game_1", player_id: "Mandor"})
  end


  test "The game is limited to 4 players" do
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerOpensLobby{game_id: "game_1", player_id: "Corwin"})
    assert Diggers.GamesStore.game_ids() == ["game_1"]
    assert Diggers.GamesStore.game("game_1").phase == "lobby"

    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerJoinsLobby{game_id: "game_1", player_id: "Mandor"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerJoinsLobby{game_id: "game_1", player_id: "Eric"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerJoinsLobby{game_id: "game_1", player_id: "Random"})
    assert Diggers.GamesStore.game("game_1").players == ["Corwin", "Mandor", "Eric", "Random"]

    {:error, :no_more_player_allowed} = Diggers.CommandedApplication.dispatch(%Diggers.PlayerJoinsLobby{game_id: "game_1", player_id: "Brand"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerLeavesLobby{game_id: "game_1", player_id: "Corwin"})
    assert Diggers.GamesStore.game("game_1").players == ["Mandor", "Eric", "Random"]

    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerJoinsLobby{game_id: "game_1", player_id: "Brand"})
    {:error, :no_more_player_allowed} = Diggers.CommandedApplication.dispatch(%Diggers.PlayerJoinsLobby{game_id: "game_1", player_id: "Fiona"})
  end


  test "A player can only leave a lobby if he joined it" do
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerOpensLobby{game_id: "game_1", player_id: "Corwin"})
    {:error, :player_not_found} = Diggers.CommandedApplication.dispatch(%Diggers.PlayerLeavesLobby{game_id: "game_1", player_id: "Mandor"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerLeavesLobby{game_id: "game_1", player_id: "Corwin"})
    {:error, :not_allowed_now} = Diggers.CommandedApplication.dispatch(%Diggers.PlayerJoinsLobby{game_id: "game_1", player_id: "Corwin"})
  end


  test "Lobby is closed when last player leave" do
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerOpensLobby{game_id: "game_1", player_id: "Corwin"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerLeavesLobby{game_id: "game_1", player_id: "Corwin"})
    assert Diggers.GamesStore.game_ids() == []
  end


  test "Only the creator can start the game" do
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerOpensLobby{game_id: "game_1", player_id: "Corwin"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerJoinsLobby{game_id: "game_1", player_id: "Mandor"})
    {:error, :not_allowed} = Diggers.CommandedApplication.dispatch(%Diggers.PlayerStartsGame{game_id: "game_1", player_id: "Mandor"})
  end


  test "Creator can only start a game with at least 2 players" do
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerOpensLobby{game_id: "game_1", player_id: "Corwin"})
    {:error, :not_enough_players} = Diggers.CommandedApplication.dispatch(%Diggers.PlayerStartsGame{game_id: "game_1", player_id: "Corwin"})
  end


  test "A player can't disable a tile until the game is started" do
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerOpensLobby{game_id: "game_1", player_id: "Corwin"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerJoinsLobby{game_id: "game_1", player_id: "Mandor"})
    {:error, :not_allowed_now} = Diggers.CommandedApplication.dispatch(%Diggers.PlayerDisablesTile{game_id: "game_1", player_id: "Corwin", tile: "1_1"})
  end


  test "An unknown player can't disable a tile" do
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerOpensLobby{game_id: "game_1", player_id: "Corwin"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerJoinsLobby{game_id: "game_1", player_id: "Mandor"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerStartsGame{game_id: "game_1", player_id: "Corwin"})
    {:error, :player_not_found} = Diggers.CommandedApplication.dispatch(%Diggers.PlayerDisablesTile{game_id: "game_1", player_id: "Eric", tile: "1_1"})
  end


  test "A player can't disable a tile that is out of board" do
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerOpensLobby{game_id: "game_1", player_id: "Corwin"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerJoinsLobby{game_id: "game_1", player_id: "Mandor"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerStartsGame{game_id: "game_1", player_id: "Corwin"})
    {:error, :tile_not_found} = Diggers.CommandedApplication.dispatch(%Diggers.PlayerDisablesTile{game_id: "game_1", player_id: "Corwin", tile: "10_10"})
  end


  test "A player can't disable tiles start, exit nor diamond tiles" do
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerOpensLobby{game_id: "game_1", player_id: "Corwin"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerJoinsLobby{game_id: "game_1", player_id: "Mandor"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerStartsGame{game_id: "game_1", player_id: "Corwin"})
    {:error, :not_allowed_on_special_tiles} = Diggers.CommandedApplication.dispatch(%Diggers.PlayerDisablesTile{game_id: "game_1", player_id: "Corwin", tile: "3_5"})
    {:error, :not_allowed_on_special_tiles} = Diggers.CommandedApplication.dispatch(%Diggers.PlayerDisablesTile{game_id: "game_1", player_id: "Corwin", tile: "9_9"})
    {:error, :not_allowed_on_special_tiles} = Diggers.CommandedApplication.dispatch(%Diggers.PlayerDisablesTile{game_id: "game_1", player_id: "Corwin", tile: "0_0"})
  end


  test "A player can't disable a tile twice" do
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerOpensLobby{game_id: "game_1", player_id: "Corwin"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerJoinsLobby{game_id: "game_1", player_id: "Mandor"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerStartsGame{game_id: "game_1", player_id: "Corwin"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerDisablesTile{game_id: "game_1", player_id: "Corwin", tile: "1_2"})
    {:error, :already_disabled} = Diggers.CommandedApplication.dispatch(%Diggers.PlayerDisablesTile{game_id: "game_1", player_id: "Corwin", tile: "1_2"})
  end


  test "A player can't disable a tile adjacent to a disabled tile" do
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerOpensLobby{game_id: "game_1", player_id: "Corwin"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerJoinsLobby{game_id: "game_1", player_id: "Mandor"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerStartsGame{game_id: "game_1", player_id: "Corwin"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerDisablesTile{game_id: "game_1", player_id: "Corwin", tile: "1_2"})
    {:error, :neighbour_already_disabled} = Diggers.CommandedApplication.dispatch(%Diggers.PlayerDisablesTile{game_id: "game_1", player_id: "Corwin", tile: "2_2"})
  end


  test "A player can't disable more than three tiles on the board" do
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerOpensLobby{game_id: "game_1", player_id: "Corwin"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerJoinsLobby{game_id: "game_1", player_id: "Mandor"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerStartsGame{game_id: "game_1", player_id: "Corwin"})
    assert Diggers.GamesStore.game("game_1").phase == "disabling"
    assert Diggers.GamesStore.game("game_1").disabled_tiles[0] == []
    assert Diggers.GamesStore.game("game_1").disabled_tiles[1] == []
    assert Diggers.GamesStore.game("game_1")["Corwin"].tiles_to_disable == 3
    assert Diggers.GamesStore.game("game_1")["Corwin"].board_index == 0
    assert Diggers.GamesStore.game("game_1")["Corwin"].lifes == 5
    assert Diggers.GamesStore.game("game_1")["Corwin"].path == ["0_0"]
    assert Diggers.GamesStore.game("game_1")["Mandor"].tiles_to_disable == 3
    assert Diggers.GamesStore.game("game_1")["Mandor"].board_index == 1
    assert Diggers.GamesStore.game("game_1")["Mandor"].lifes == 5
    assert Diggers.GamesStore.game("game_1")["Mandor"].path == ["0_0"]

    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerDisablesTile{game_id: "game_1", player_id: "Corwin", tile: "1_4"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerDisablesTile{game_id: "game_1", player_id: "Corwin", tile: "1_2"})
    assert Diggers.GamesStore.game("game_1")["Corwin"].tiles_to_disable == 1
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerDisablesTile{game_id: "game_1", player_id: "Corwin", tile: "1_0"})
    {:error, :no_more_disabling_allowed} = Diggers.CommandedApplication.dispatch(%Diggers.PlayerDisablesTile{game_id: "game_1", player_id: "Corwin", tile: "3_1"})
    assert Diggers.GamesStore.game("game_1").disabled_tiles[0] == ["1_4", "1_2", "1_0"]
  end


  test "A simple game" do
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerOpensLobby{game_id: "game_1", player_id: "Corwin"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerJoinsLobby{game_id: "game_1", player_id: "Mandor"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerStartsGame{game_id: "game_1", player_id: "Corwin"})

    {:error, :not_allowed_now} = Diggers.CommandedApplication.dispatch(%Diggers.PlayerLeavesLobby{game_id: "game_1", player_id: "Corwin"})
    {:error, :not_allowed_now} = Diggers.CommandedApplication.dispatch(%Diggers.PlayerJoinsLobby{game_id: "game_1", player_id: "Eric"})

    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerDisablesTile{game_id: "game_1", player_id: "Corwin", tile: "1_3"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerDisablesTile{game_id: "game_1", player_id: "Corwin", tile: "0_1"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerDisablesTile{game_id: "game_1", player_id: "Corwin", tile: "3_4"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerDisablesTile{game_id: "game_1", player_id: "Mandor", tile: "1_0"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerDisablesTile{game_id: "game_1", player_id: "Mandor", tile: "3_2"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerDisablesTile{game_id: "game_1", player_id: "Mandor", tile: "5_4"})

    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerDisablesTile{game_id: "game_1", player_id: "Corwin", tile: "2_3"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerDisablesTile{game_id: "game_1", player_id: "Corwin", tile: "0_1"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerDisablesTile{game_id: "game_1", player_id: "Corwin", tile: "3_0"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerDisablesTile{game_id: "game_1", player_id: "Mandor", tile: "8_8"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerDisablesTile{game_id: "game_1", player_id: "Mandor", tile: "2_2"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerDisablesTile{game_id: "game_1", player_id: "Mandor", tile: "4_3"})
    assert Diggers.GamesStore.game("game_1").phase == "exploration"

    {:error, :not_allowed_now} = Diggers.CommandedApplication.dispatch(%Diggers.PlayerStartsGame{game_id: "game_1", player_id: "Corwin"})
    {:error, :not_allowed_now} = Diggers.CommandedApplication.dispatch(%Diggers.PlayerDisablesTile{game_id: "game_1", player_id: "Corwin", tile: "1_2"})

    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerRollsDices{game_id: "game_1", dices_rolls: [1, 2, 2, 1]})
    {:error, :dices_already_rolled} = Diggers.CommandedApplication.dispatch(%Diggers.PlayerRollsDices{game_id: "game_1", dices_rolls: [1, 2, 2, 1]})
    assert Diggers.GamesStore.game("game_1").dices_rolls == [1, 2, 2, 1]
    assert Diggers.GamesStore.game("game_1")["Mandor"].lifes == 4
    assert Diggers.GamesStore.game("game_1")["Mandor"].current_round == "suffocated"
    assert Diggers.GamesStore.game("game_1")["Corwin"].lifes == 5
    assert Diggers.GamesStore.game("game_1")["Corwin"].current_round == nil

    {:error, :player_not_found} = Diggers.CommandedApplication.dispatch(%Diggers.PlayerMoves{game_id: "game_1", player_id: "Eric", tile: "1_1"})
    {:error, :suffocated_this_round} = Diggers.CommandedApplication.dispatch(%Diggers.PlayerMoves{game_id: "game_1", player_id: "Mandor", tile: "1_1"})
    {:error, :tile_not_in_neighbours} = Diggers.CommandedApplication.dispatch(%Diggers.PlayerMoves{game_id: "game_1", player_id: "Corwin", tile: "9_9"})
    {:error, :tile_is_disabled} = Diggers.CommandedApplication.dispatch(%Diggers.PlayerMoves{game_id: "game_1", player_id: "Corwin", tile: "0_1"})
    {:error, :tile_is_unavailable} = Diggers.CommandedApplication.dispatch(%Diggers.PlayerMoves{game_id: "game_1", player_id: "Corwin", tile: "1_1"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerMoves{game_id: "game_1", player_id: "Corwin", tile: "1_0"})
    assert Diggers.GamesStore.game("game_1")["Corwin"].current_round == nil
    assert Diggers.GamesStore.game("game_1")["Corwin"].path == ["1_0", "0_0"]
    assert Diggers.GamesStore.game("game_1")["Corwin"].current_round == nil
    assert Diggers.GamesStore.game("game_1")["Mandor"].path == ["0_0"]
    assert Diggers.GamesStore.game("game_1").dices_rolls == nil

    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerRollsDices{game_id: "game_1", dices_rolls: [3, 3, 5, 6]})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerMoves{game_id: "game_1", player_id: "Corwin", tile: "2_1"})
    {:error, :already_moved_this_round} = Diggers.CommandedApplication.dispatch(%Diggers.PlayerMoves{game_id: "game_1", player_id: "Corwin", tile: "2_1"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerMoves{game_id: "game_1", player_id: "Mandor", tile: "1_1"})

    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerRollsDices{game_id: "game_1", dices_rolls: [3, 4, 5, 2]})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerMoves{game_id: "game_1", player_id: "Mandor", tile: "2_2"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerMoves{game_id: "game_1", player_id: "Corwin", tile: "3_2"})

    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerRollsDices{game_id: "game_1", dices_rolls: [3, 4, 5, 6]})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerMoves{game_id: "game_1", player_id: "Corwin", tile: "4_2"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerMoves{game_id: "game_1", player_id: "Mandor", tile: "3_3"})

    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerRollsDices{game_id: "game_1", dices_rolls: [1, 2, 4, 5]})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerMoves{game_id: "game_1", player_id: "Corwin", tile: "5_3"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerMoves{game_id: "game_1", player_id: "Mandor", tile: "4_4"})

    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerRollsDices{game_id: "game_1", dices_rolls: [1, 2, 4, 5]})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerMoves{game_id: "game_1", player_id: "Corwin", tile: "6_4"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerMoves{game_id: "game_1", player_id: "Mandor", tile: "5_5"})

    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerRollsDices{game_id: "game_1", dices_rolls: [3, 3, 3, 3]})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerMoves{game_id: "game_1", player_id: "Corwin", tile: "6_5"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerMoves{game_id: "game_1", player_id: "Mandor", tile: "6_5"})

    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerRollsDices{game_id: "game_1", dices_rolls: [2, 2, 2, 2]})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerMoves{game_id: "game_1", player_id: "Corwin", tile: "7_6"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerMoves{game_id: "game_1", player_id: "Mandor", tile: "7_6"})

    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerRollsDices{game_id: "game_1", dices_rolls: [4, 4, 4, 4]})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerMoves{game_id: "game_1", player_id: "Corwin", tile: "8_7"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerMoves{game_id: "game_1", player_id: "Mandor", tile: "8_7"})

    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerRollsDices{game_id: "game_1", dices_rolls: [2, 2, 3, 5]})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerMoves{game_id: "game_1", player_id: "Corwin", tile: "9_8"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerMoves{game_id: "game_1", player_id: "Mandor", tile: "8_8"})

    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerRollsDices{game_id: "game_1", dices_rolls: [2, 2, 4, 5]})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerMoves{game_id: "game_1", player_id: "Corwin", tile: "9_9"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerMoves{game_id: "game_1", player_id: "Mandor", tile: "8_9"})

    {:error, :too_many_dices_rolls} = Diggers.CommandedApplication.dispatch(%Diggers.PlayerRollsDices{game_id: "game_1", dices_rolls: [2, 2, 4, 5]})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerRollsDices{game_id: "game_1", dices_rolls: [2, 3, 4]})
    {:error, :player_already_left} = Diggers.CommandedApplication.dispatch(%Diggers.PlayerMoves{game_id: "game_1", player_id: "Corwin", tile: "9_9"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerMoves{game_id: "game_1", player_id: "Mandor", tile: "9_9"})

    {:error, :not_allowed_now} = Diggers.CommandedApplication.dispatch(%Diggers.PlayerRollsDices{game_id: "game_1", dices_rolls: [2, 2, 4, 5]})
    {:error, :not_allowed_now} = Diggers.CommandedApplication.dispatch(%Diggers.PlayerMoves{game_id: "game_1", player_id: "Mandor", tile: "9_9"})
    assert Diggers.GamesStore.game("game_1").phase == "results"
    assert Diggers.GamesStore.game("game_1").winners == [%{"player_id" => "Corwin", "score" => 16}, %{"player_id" => "Mandor", "score" => 8}]

    [{16, "Corwin"}, {8, "Mandor"}] = Diggers.Game.winners(game())
  end


  test "Gone players are not counted in 'all players suffocated' or 'all players acted' so the game can continue for others" do
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerOpensLobby{game_id: "game_1", player_id: "Corwin"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerJoinsLobby{game_id: "game_1", player_id: "Mandor"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerStartsGame{game_id: "game_1", player_id: "Corwin"})

    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerDisablesTile{game_id: "game_1", player_id: "Corwin", tile: "1_3"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerDisablesTile{game_id: "game_1", player_id: "Corwin", tile: "0_1"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerDisablesTile{game_id: "game_1", player_id: "Corwin", tile: "3_4"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerDisablesTile{game_id: "game_1", player_id: "Mandor", tile: "1_0"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerDisablesTile{game_id: "game_1", player_id: "Mandor", tile: "3_2"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerDisablesTile{game_id: "game_1", player_id: "Mandor", tile: "5_4"})

    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerDisablesTile{game_id: "game_1", player_id: "Corwin", tile: "2_3"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerDisablesTile{game_id: "game_1", player_id: "Corwin", tile: "0_1"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerDisablesTile{game_id: "game_1", player_id: "Corwin", tile: "3_0"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerDisablesTile{game_id: "game_1", player_id: "Mandor", tile: "8_9"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerDisablesTile{game_id: "game_1", player_id: "Mandor", tile: "2_2"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerDisablesTile{game_id: "game_1", player_id: "Mandor", tile: "4_3"})

    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerRollsDices{game_id: "game_1", dices_rolls: [2, 3, 5, 2]})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerMoves{game_id: "game_1", player_id: "Corwin", tile: "1_0"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerMoves{game_id: "game_1", player_id: "Mandor", tile: "1_1"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerRollsDices{game_id: "game_1", dices_rolls: [2, 2, 5, 2]})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerMoves{game_id: "game_1", player_id: "Mandor", tile: "2_1"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerMoves{game_id: "game_1", player_id: "Corwin", tile: "2_1"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerRollsDices{game_id: "game_1", dices_rolls: [2, 2, 2, 3]})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerMoves{game_id: "game_1", player_id: "Corwin", tile: "3_2"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerMoves{game_id: "game_1", player_id: "Mandor", tile: "1_1"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerRollsDices{game_id: "game_1", dices_rolls: [2, 2, 2, 5]})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerMoves{game_id: "game_1", player_id: "Corwin", tile: "3_3"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerMoves{game_id: "game_1", player_id: "Mandor", tile: "2_1"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerRollsDices{game_id: "game_1", dices_rolls: [1, 1, 1, 1]})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerMoves{game_id: "game_1", player_id: "Corwin", tile: "4_4"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerMoves{game_id: "game_1", player_id: "Mandor", tile: "3_1"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerRollsDices{game_id: "game_1", dices_rolls: [2, 3, 5, 6]})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerMoves{game_id: "game_1", player_id: "Corwin", tile: "5_5"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerMoves{game_id: "game_1", player_id: "Mandor", tile: "2_1"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerRollsDices{game_id: "game_1", dices_rolls: [2, 3, 5, 6]})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerMoves{game_id: "game_1", player_id: "Corwin", tile: "6_6"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerMoves{game_id: "game_1", player_id: "Mandor", tile: "1_1"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerRollsDices{game_id: "game_1", dices_rolls: [2, 3, 5, 6]})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerMoves{game_id: "game_1", player_id: "Corwin", tile: "7_7"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerMoves{game_id: "game_1", player_id: "Mandor", tile: "2_1"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerRollsDices{game_id: "game_1", dices_rolls: [2, 3, 5, 6]})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerMoves{game_id: "game_1", player_id: "Corwin", tile: "8_8"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerMoves{game_id: "game_1", player_id: "Mandor", tile: "1_1"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerRollsDices{game_id: "game_1", dices_rolls: [2, 3, 5, 6]})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerMoves{game_id: "game_1", player_id: "Corwin", tile: "9_9"}) # Corwin leaves.
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerMoves{game_id: "game_1", player_id: "Mandor", tile: "2_1"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerRollsDices{game_id: "game_1", dices_rolls: [2, 3, 5]})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerMoves{game_id: "game_1", player_id: "Mandor", tile: "1_1"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerRollsDices{game_id: "game_1", dices_rolls: [6, 6, 6]}) # Mandor suffocates.
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerRollsDices{game_id: "game_1", dices_rolls: [1, 2, 3]})

    [{10, "Corwin"}] = Diggers.Game.winners(game())
  end


  test "A game where everybody dies" do
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerOpensLobby{game_id: "game_1", player_id: "Corwin"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerJoinsLobby{game_id: "game_1", player_id: "Mandor"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerStartsGame{game_id: "game_1", player_id: "Corwin"})

    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerDisablesTile{game_id: "game_1", player_id: "Corwin", tile: "1_3"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerDisablesTile{game_id: "game_1", player_id: "Corwin", tile: "0_1"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerDisablesTile{game_id: "game_1", player_id: "Corwin", tile: "3_4"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerDisablesTile{game_id: "game_1", player_id: "Mandor", tile: "1_0"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerDisablesTile{game_id: "game_1", player_id: "Mandor", tile: "3_2"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerDisablesTile{game_id: "game_1", player_id: "Mandor", tile: "5_4"})

    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerDisablesTile{game_id: "game_1", player_id: "Corwin", tile: "2_3"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerDisablesTile{game_id: "game_1", player_id: "Corwin", tile: "0_1"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerDisablesTile{game_id: "game_1", player_id: "Corwin", tile: "3_0"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerDisablesTile{game_id: "game_1", player_id: "Mandor", tile: "8_8"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerDisablesTile{game_id: "game_1", player_id: "Mandor", tile: "2_2"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerDisablesTile{game_id: "game_1", player_id: "Mandor", tile: "4_3"})

    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerRollsDices{game_id: "game_1", dices_rolls: [2, 2, 2, 2]})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerRollsDices{game_id: "game_1", dices_rolls: [2, 2, 2, 2]})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerRollsDices{game_id: "game_1", dices_rolls: [2, 2, 2, 2]})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerRollsDices{game_id: "game_1", dices_rolls: [2, 2, 2, 5]})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerMoves{game_id: "game_1", player_id: "Corwin", tile: "1_0"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerRollsDices{game_id: "game_1", dices_rolls: [2, 2, 2, 2]}) # Kill Mandor.
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerRollsDices{game_id: "game_1", dices_rolls: [2, 3, 4, 5]})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerMoves{game_id: "game_1", player_id: "Corwin", tile: "2_1"})
    {:error, :player_is_dead} = Diggers.CommandedApplication.dispatch(%Diggers.PlayerMoves{game_id: "game_1", player_id: "Mandor", tile: "2_1"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerRollsDices{game_id: "game_1", dices_rolls: [2, 3, 4, 5]})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerMoves{game_id: "game_1", player_id: "Corwin", tile: "3_2"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerRollsDices{game_id: "game_1", dices_rolls: [2, 2, 2, 2]})

    [] = Diggers.Game.winners(game())
  end


  test "A player dies, the other survives." do
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerOpensLobby{game_id: "game_1", player_id: "Corwin"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerJoinsLobby{game_id: "game_1", player_id: "Mandor"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerStartsGame{game_id: "game_1", player_id: "Corwin"})

    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerDisablesTile{game_id: "game_1", player_id: "Corwin", tile: "1_3"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerDisablesTile{game_id: "game_1", player_id: "Corwin", tile: "0_1"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerDisablesTile{game_id: "game_1", player_id: "Corwin", tile: "3_4"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerDisablesTile{game_id: "game_1", player_id: "Mandor", tile: "1_0"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerDisablesTile{game_id: "game_1", player_id: "Mandor", tile: "3_2"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerDisablesTile{game_id: "game_1", player_id: "Mandor", tile: "5_4"})

    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerDisablesTile{game_id: "game_1", player_id: "Corwin", tile: "2_3"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerDisablesTile{game_id: "game_1", player_id: "Corwin", tile: "0_1"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerDisablesTile{game_id: "game_1", player_id: "Corwin", tile: "3_0"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerDisablesTile{game_id: "game_1", player_id: "Mandor", tile: "8_9"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerDisablesTile{game_id: "game_1", player_id: "Mandor", tile: "2_2"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerDisablesTile{game_id: "game_1", player_id: "Mandor", tile: "4_3"})

    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerRollsDices{game_id: "game_1", dices_rolls: [2, 2, 5, 2]})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerMoves{game_id: "game_1", player_id: "Corwin", tile: "1_0"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerRollsDices{game_id: "game_1", dices_rolls: [2, 2, 5, 2]})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerMoves{game_id: "game_1", player_id: "Corwin", tile: "2_1"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerRollsDices{game_id: "game_1", dices_rolls: [2, 2, 2, 2]})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerMoves{game_id: "game_1", player_id: "Corwin", tile: "3_2"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerRollsDices{game_id: "game_1", dices_rolls: [2, 2, 2, 5]})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerMoves{game_id: "game_1", player_id: "Corwin", tile: "3_3"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerRollsDices{game_id: "game_1", dices_rolls: [1, 1, 1, 1]})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerMoves{game_id: "game_1", player_id: "Corwin", tile: "4_4"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerRollsDices{game_id: "game_1", dices_rolls: [2, 3, 5, 6]})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerMoves{game_id: "game_1", player_id: "Corwin", tile: "5_5"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerRollsDices{game_id: "game_1", dices_rolls: [2, 3, 5, 6]})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerMoves{game_id: "game_1", player_id: "Corwin", tile: "6_6"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerRollsDices{game_id: "game_1", dices_rolls: [2, 3, 5, 6]})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerMoves{game_id: "game_1", player_id: "Corwin", tile: "7_7"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerRollsDices{game_id: "game_1", dices_rolls: [2, 3, 5, 6]})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerMoves{game_id: "game_1", player_id: "Corwin", tile: "8_8"})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerRollsDices{game_id: "game_1", dices_rolls: [2, 3, 5, 6]})
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerMoves{game_id: "game_1", player_id: "Corwin", tile: "9_9"})

    [{10, "Corwin"}] = Diggers.Game.winners(game())
  end


  defp game(game_id \\ "game_1") do
    Commanded.Aggregates.Aggregate.aggregate_state(Diggers.CommandedApplication, Diggers.Game, game_id)
  end
end
