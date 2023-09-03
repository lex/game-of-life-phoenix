defmodule GameOfLifeWeb.Game do
  def step(board) do
    board
    |> Enum.with_index()
    |> Enum.map(fn {row, i} ->
      row
      |> Enum.with_index()
      |> Enum.map(fn {cell, j} -> next_state(cell, i, j, board) end)
    end)
  end

  defp next_state(:alive, i, j, board) do
    case alive_neighbors(i, j, board) do
      2 -> :alive
      3 -> :alive
      _ -> :dead
    end
  end

  defp next_state(:dead, i, j, board) do
    case alive_neighbors(i, j, board) do
      3 -> :alive
      _ -> :dead
    end
  end

  defp alive_neighbors(i, j, board) do
    [-1, 0, 1]
    |> Enum.flat_map(&Enum.map([-1, 0, 1], fn dy -> {&1, dy} end))
    |> Enum.reject(&(&1 == {0, 0}))
    |> Enum.count(fn {dx, dy} ->
      Enum.at(Enum.at(board, i + dx, []), j + dy) == :alive
    end)
  end

  def toggle_cell(board, row, col) do
    Enum.with_index(board)
    |> Enum.map(fn
      {row_cells, row_idx} when row_idx == row ->
        Enum.with_index(row_cells)
        |> Enum.map(fn
          {cell, col_idx} when col_idx == col -> toggle(cell)
          {cell, _} -> cell
        end)

      {row_cells, _} ->
        row_cells
    end)
  end

  defp toggle(:alive), do: :dead
  defp toggle(:dead), do: :alive
end
