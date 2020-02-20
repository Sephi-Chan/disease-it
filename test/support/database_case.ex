defmodule Diggers.DatabaseCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      import Commanded.Assertions.EventAssertions
    end
  end


  setup do
    {:ok, _} = Application.ensure_all_started(:diggers)

    on_exit(fn ->
      :ok = Application.stop(:diggers)
      :ok = Application.stop(:commanded)
      :ok = Application.stop(:eventstore)

      config = Application.get_env(:diggers, Diggers.EventStore) |> EventStore.Config.default_postgrex_opts()
      {:ok, conn} = Postgrex.start_link(config)

      EventStore.Storage.Initializer.reset!(conn)
    end)

    :ok
  end
end
