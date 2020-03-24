defmodule DiggersWeb.PlayerChannel do
  use Phoenix.Channel


  def join("player:" <> player_id, _message, socket) do
    if player_id == socket.assigns.player_id do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end


  def handle_in("open_lobby", _params, socket) do
    game_id = UUID.uuid4()
    :ok = Diggers.CommandedApplication.dispatch(%Diggers.PlayerOpensLobby{game_id: game_id, player_id: socket.assigns.player_id})
    response = %{"game_id" => game_id}

    {:reply, {:ok, response}, socket}
  end
end
