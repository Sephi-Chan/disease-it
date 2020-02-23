defmodule Diggers.MixProject do
  use Mix.Project

  def project do
    [
      app: :diggers,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers()
    ]
  end


  def application do
    [
      extra_applications: [:logger, :eventstore, :runtime_tools],
      mod: {Diggers.Application, []}
    ]
  end


  defp deps do
    [
      {:commanded, "~> 1.0.0"},
      {:jason, "~> 1.1"},
      {:commanded_eventstore_adapter, "~> 1.0.0"},
      {:mix_test_watch, "~> 1.0", only: :dev, runtime: false},
      {:phoenix, "~> 1.4.13"},
      {:phoenix_pubsub, "~> 1.1"},
      {:phoenix_html, "~> 2.11"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:gettext, "~> 0.11"},
      {:plug_cowboy, "~> 2.0"},
      {:elixir_uuid, "~> 1.2"},
      {:task_after, "~> 1.2"}
    ]
  end


  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end
