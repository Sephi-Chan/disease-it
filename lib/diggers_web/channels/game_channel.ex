defmodule DiggersWeb.GameChannel do
  use Phoenix.Channel


  def join("game:" <> game_id, _message, socket) do
    game = Diggers.GamesStore.game(game_id)

    cond do
      game && game.phase == "lobby" ->
        TaskAfter.cancel_task_after({Diggers.PlayerLeavesLobby, game_id, socket.assigns.player_id})
        {:ok, game, assign(socket, :game_id, game_id)}

      game && game.phase != "lobby" && Enum.member?(game.players, socket.assigns.player_id)->
        {:ok, game, assign(socket, :game_id, game_id)}

      true ->
        {:error, %{reason: "unauthorized"}}
    end
  end


  def handle_in("open_lobby", _params, socket) do
    game_id = UUID.uuid4()
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerOpensLobby{game_id: game_id, player_id: socket.assigns.player_id})
    response = %{"game_id" => game_id}

    {:reply, {:ok, response}, socket}
  end


  def handle_in("start_disabling_phase", _params, socket) do
    Diggers.CommandedApplication.dispatch(%Diggers.PlayerStartsGame{game_id: socket.assigns.game_id, player_id: socket.assigns.player_id, board: Diggers.Board.disease_it})
    {:reply, {:ok, %{}}, socket}
  end


  def handle_in("player_disables_tile", params, socket) do
    Diggers.CommandedApplication.dispatch(%Diggers.PlayerDisablesTile{game_id: socket.assigns.game_id, player_id: socket.assigns.player_id, tile: params["tile"]})
    {:reply, {:ok, %{}}, socket}
  end


  def handle_in("player_rolls_dices", _params, socket) do
    Diggers.CommandedApplication.dispatch(%Diggers.PlayerRollsDices{game_id: socket.assigns.game_id, dices_rolls: Diggers.Dice.roll(4)})
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
