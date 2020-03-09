defmodule DiggersWeb.Router do
  use DiggersWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", DiggersWeb do
    pipe_through :browser

    get "/", PageController, :home
    get "/g/:game_id", PageController, :game
  end
end
