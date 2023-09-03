defmodule GameOfLifeWeb.Board do
  def new(rows, cols) do
    Enum.map(1..rows, fn _ ->
      Enum.map(1..cols, fn _ -> Enum.random([:alive, :dead]) end)
    end)
  end
end
