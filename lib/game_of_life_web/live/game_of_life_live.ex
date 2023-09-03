defmodule GameOfLifeWeb.GameOfLifeLive do
  use GameOfLifeWeb, :live_view

  # milliseconds
  @tick_rate 33
  @topic "game_of_life"

  @impl true
  def mount(_params, _session, socket) do
    board = GameOfLifeWeb.SharedBoard.get_board()
    send(self(), :tick)

    # Subscribe to the PubSub topic
    GameOfLifeWeb.Endpoint.subscribe(@topic)

    {:ok, assign(socket, board: board)}
  end

  @impl true
  def handle_info(:tick, socket) do
    new_board = GameOfLifeWeb.Game.step(socket.assigns.board)

    string_board =
      Enum.map(new_board, fn row ->
        Enum.map(row, fn cell ->
          Atom.to_string(cell)
        end)
      end)

    Process.send_after(self(), :tick, @tick_rate)

    {:noreply,
     assign(socket, board: new_board) |> push_event("renderGame", %{board: string_board})}
  end

  # Handle the board updates
  @impl true
  def handle_info(
        %Phoenix.Socket.Broadcast{topic: @topic, event: "board_update", payload: new_board},
        socket
      ) do
    {:noreply, assign(socket, board: new_board)}
  end

  @impl true
  def render(assigns) do
    ~L"""
    <canvas id="gameCanvas" width="640" height="640" phx-hook="GameCanvas"></canvas>
    """
  end

  @impl true
  def handle_event("toggle_cell", %{"row" => row, "col" => col}, socket) do
    row = String.to_integer(row)
    col = String.to_integer(col)

    # Retrieve the current board and toggle the cell at (row, col)
    board = socket.assigns.board
    new_board = GameOfLifeWeb.Game.toggle_cell(board, row, col)

    # Update the shared board
    GameOfLifeWeb.SharedBoard.set_board(new_board)

    # Broadcast the new board state to all subscribers
    GameOfLifeWeb.Endpoint.broadcast(@topic, "board_update", new_board)

    {:noreply, assign(socket, board: new_board)}
  end

  @impl true
  def handle_event("start", _value, socket) do
    if is_nil(socket.assigns.timer) do
      timer = Process.send_after(self(), :tick, @tick_rate)
      {:noreply, assign(socket, timer: timer)}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_event("stop", _value, socket) do
    if socket.assigns.timer do
      Process.cancel_timer(socket.assigns.timer)
      {:noreply, assign(socket, timer: nil)}
    else
      {:noreply, socket}
    end
  end
end
