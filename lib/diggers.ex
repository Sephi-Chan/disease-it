defmodule Diggers do
  use Application


  def start(_type, _args) do
    Diggers.Supervisor.start_link()
  end
end
