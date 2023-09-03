defmodule GameOfLifeWeb.SharedBoard do
  use GenServer

  @rows 32
  @columns 32
  @tick_rate 33
  @topic "game_of_life"

  @initial_board GameOfLifeWeb.Board.new(@rows, @columns)

  # API
  def start_link(_) do
    GenServer.start_link(__MODULE__, @initial_board, name: __MODULE__)
  end

  def get_board do
    GenServer.call(__MODULE__, :get_board)
  end

  def step_board do
    GenServer.cast(__MODULE__, :step_board)
  end

  @impl true
  def init(board) do
    Process.send_after(self(), :tick, @tick_rate)
    {:ok, %{board: board}}
  end

  @impl true
  def handle_call(:get_board, _from, state) do
    {:reply, state[:board], state}
  end

  @impl true
  def handle_call({:toggle_cell, row, col}, _from, %{board: board} = state) do
    IO.puts("Toggling cell at (#{row}, #{col})")
    new_board = GameOfLifeWeb.Game.toggle_cell(board, row, col)
    {:reply, :ok, %{state | board: new_board}}
  end

  @impl true
  def handle_cast(:step_board, state) do
    new_board = GameOfLifeWeb.Game.step(state[:board])
    {:noreply, %{state | board: new_board}}
  end

  def set_board(new_board) do
    GenServer.cast(__MODULE__, {:set_board, new_board})
  end

  @impl true
  def handle_info(:tick, %{board: board} = state) do
    new_board = GameOfLifeWeb.Game.step(board)
    GameOfLifeWeb.Endpoint.broadcast(@topic, "board_update", new_board)
    Process.send_after(self(), :tick, @tick_rate)
    {:noreply, %{state | board: new_board}}
  end

  def toggle_cell(row, col) do
    GenServer.call(__MODULE__, {:toggle_cell, row, col})
  end
end
