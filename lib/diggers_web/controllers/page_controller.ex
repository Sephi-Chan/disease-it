defmodule DiggersWeb.PageController do
  use DiggersWeb, :controller

  plug :identify_player
  plug :ensure_game_availability


  def index(conn, params) do
    conn
      |> assign(:game_id, params["game_id"])
      |> render("index.html")
  end


  defp identify_player(conn, _params) do
    player_id = get_session(conn, "player_id") || UUID.uuid4()

    conn
      |> put_session("player_id", player_id)
      |> assign(:player_id, player_id)
  end


  defp ensure_game_availability(conn, _params) do
    game = Diggers.GamesStore.game(conn.params["game_id"])

    cond do
      conn.params["game_id"] && game == nil ->
        conn |> halt |> redirect(to: "/")

      game == nil ->
        conn

      game.phase != "lobby" ->
        conn |> halt |> redirect(to: "/")

      game.phase == "lobby" && Enum.member?(game.players, conn.assigns.player_id) ->
        conn

      game.phase == "lobby" && !Enum.member?(game.players, conn.assigns.player_id) ->
        Diggers.CommandedApplication.dispatch(%Diggers.PlayerJoinsLobby{game_id: game.game_id, player_id: conn.assigns.player_id})
        conn
    end
  end
end
