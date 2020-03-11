defmodule Diggers.Dice do
  def roll(count) do
    Enum.map(1..count, fn (_i) -> :rand.uniform(6) end)
  end
end
