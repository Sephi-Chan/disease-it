defmodule DiggersWeb.GeneralChannel do
  use Phoenix.Channel


  def join("general", _message, socket) do
    if socket.assigns.player_id do
      {:ok, %{games: Diggers.GamesStore.open_lobbies}, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end
end
