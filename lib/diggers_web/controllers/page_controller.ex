defmodule DiggersWeb.PageController do
  use DiggersWeb, :controller

  plug :identify_player
  plug :ensure_game_availability when action in [:game]


  def home(conn, params) do
    conn
      |> assign(:game_id, params["game_id"])
      |> render("home.html")
  end


  def game(conn, params) do
    conn
      |> assign(:game_id, params["game_id"])
      |> render("game.html")
  end


  defp identify_player(conn, _params) do
    player_id = get_session(conn, "player_id") || UUID.uuid4()

    conn
      |> put_session("player_id", player_id)
      |> assign(:player_token, Phoenix.Token.sign(DiggersWeb.Endpoint, "salt", player_id))
      |> assign(:player_id, player_id)
  end


  defp ensure_game_availability(conn, _params) do
    game = Diggers.GamesStore.game(conn.params["game_id"])

    cond do
      # Game not found.
      game == nil ->
        conn |> halt |> put_flash(:error, "not_found") |> redirect(to: "/")

      # The game started and the player is not in it.
      game.phase != "lobby" && !Enum.member?(game.players, conn.assigns.player_id) ->
        conn |> halt |> put_flash(:error, "already_started") |> redirect(to: "/")

      # The lobby is full but not started yet.
      game.phase == "lobby" && Enum.count(game.players) == 4 ->
        conn |> halt |> put_flash(:error, "full") |> redirect(to: "/")

      # Show the game page.
      game.phase != "lobby" && Enum.member?(game.players, conn.assigns.player_id) ->
        conn |> assign(:game, game)

      # Show the lobby page.
      game.phase == "lobby" && Enum.member?(game.players, conn.assigns.player_id) ->
        conn

      # Add the player to the game and show the lobby page.
      game.phase == "lobby" && !Enum.member?(game.players, conn.assigns.player_id) ->
        Diggers.CommandedApplication.dispatch(%Diggers.PlayerJoinsLobby{game_id: game.game_id, player_id: conn.assigns.player_id})
        conn
    end
  end
end
