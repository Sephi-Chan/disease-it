defmodule Diggers.Supervisor do
  use Supervisor


  def start_link() do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end


  def init(_args) do
    children = [Diggers.Application]
    Supervisor.init(children, strategy: :one_for_one)
  end
end
