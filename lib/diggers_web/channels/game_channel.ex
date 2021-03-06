defmodule DiggersWeb.GameChannel do
  use Phoenix.Channel


  def join("game:" <> game_id, _message, socket) do
    game = Diggers.GamesStore.game(game_id)

    cond do
      game && game.phase == "lobby" ->
        Diggers.CommandedApplication.dispatch(%Diggers.PlayerJoinsLobby{game_id: game.game_id, player_id: socket.assigns.player_id}, consistency: :strong)
        game_after = Diggers.GamesStore.game(game_id)
        TaskAfter.cancel_task_after({Diggers.PlayerLeavesLobby, game_id, socket.assigns.player_id})
        {:ok, game_after, assign(socket, :game_id, game_id)}

      game && game.phase != "lobby" && Enum.member?(game.players, socket.assigns.player_id)->
        {:ok, game, assign(socket, :game_id, game_id)}

      true ->
        {:error, %{reason: "unauthorized"}}
    end
  end


  def handle_in("start_exploration_phase", _params, socket) do
    board = Diggers.Board.disease_it
    disabled_tiles = Diggers.Board.random_tiles_to_disable(board, 5) |> Enum.map(fn ({x, y}) -> "#{x}_#{y}" end)

    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerStartsGame{
      game_id: socket.assigns.game_id,
      player_id: socket.assigns.player_id,
      board: board,
      disabled_tiles: disabled_tiles
    })

    {:noreply, socket}
  end


  def handle_in("player_rolls_dices", _params, socket) do
    game = Diggers.GamesStore.game(socket.assigns.game_id)
    max_dices_count = Diggers.Game.max_dices_count(game)
    Diggers.CommandedApplication.dispatch(%Diggers.PlayerRollsDices{game_id: socket.assigns.game_id, dices_rolls: Diggers.Dice.roll(max_dices_count)})
    {:reply, {:ok, %{}}, socket}
  end


  def handle_in("player_moves", params, socket) do
    Diggers.CommandedApplication.dispatch(%Diggers.PlayerMoves{game_id: socket.assigns.game_id, player_id: socket.assigns.player_id, tile: params["tile"]})
    {:reply, {:ok, %{}}, socket}
  end


  def handle_in("fetch", _params, socket) do
    game = Diggers.GamesStore.game(socket.assigns.game_id)
    {:reply, {:ok, game}, socket}
  end


  def terminate(_reason, socket) do
    if Map.has_key?(socket.assigns, :game_id) do
      game = Diggers.GamesStore.game(socket.assigns.game_id)

      if List.first(game.players) == socket.assigns.player_id do
        TaskAfter.task_after(3000, fn () ->
          Diggers.CommandedApplication.dispatch(%Diggers.PlayerLeavesLobby{game_id: socket.assigns.game_id, player_id: socket.assigns.player_id})
        end, id: {Diggers.PlayerLeavesLobby, socket.assigns.game_id, socket.assigns.player_id})
      else
        Diggers.CommandedApplication.dispatch(%Diggers.PlayerLeavesLobby{game_id: socket.assigns.game_id, player_id: socket.assigns.player_id})
      end
    end
  end
end
