defmodule Diggers.MixProject do
  use Mix.Project

  def project do
    [
      app: :diggers,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env())
    ]
  end


  def application do
    [
      extra_applications: [:logger, :eventstore],
      mod: {Diggers, []}
    ]
  end


  defp deps do
    [
      {:commanded, "~> 1.0.0"},
      {:jason, "~> 1.1"},
      {:commanded_eventstore_adapter, "~> 1.0.0"},
      {:mix_test_watch, "~> 1.0", only: :dev, runtime: false}
    ]
  end


  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end
