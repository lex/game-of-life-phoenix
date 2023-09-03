defmodule GameOfLifeWeb.SharedBoard do
  use GenServer

  @rows 32
  @columns 32

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

  # GenServer Callbacks
  @impl true
  def init(board) do
    {:ok, board}
  end

  @impl true
  def handle_call(:get_board, _from, board) do
    {:reply, board, board}
  end

  @impl true
  def handle_cast(:step_board, board) do
    new_board = GameOfLifeWeb.Game.step(board)
    {:noreply, new_board}
  end
end
