defmodule Diggers.Application do
  use Application


  def start(_type, _args) do
    children = [
      DiggersWeb.Endpoint,
      Diggers.CommandedApplication,
      Diggers.GameReadModelBuilder,
      Diggers.GamesStore
    ]

    opts = [strategy: :one_for_one, name: Diggers.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
