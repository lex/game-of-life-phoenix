defmodule GameOfLifeWeb.GameOfLifeLive do
  use GameOfLifeWeb, :live_view

  @topic "game_of_life"

  @impl true
  def mount(_params, _session, socket) do
    # Subscribe to the PubSub topic
    GameOfLifeWeb.Endpoint.subscribe(@topic)

    {:ok, assign(socket, board: [])}
  end

  # Handle the board updates
  @impl true
  def handle_info(
        %Phoenix.Socket.Broadcast{topic: @topic, event: "board_update", payload: new_board},
        socket
      ) do
    string_board =
      Enum.map(new_board, fn row ->
        Enum.map(row, fn cell ->
          Atom.to_string(cell)
        end)
      end)

    {:noreply,
     assign(socket, board: string_board) |> push_event("renderGame", %{board: string_board})}
  end

  @impl true
  def render(assigns) do
    ~L"""
    <canvas id="gameCanvas" width="640" height="640" phx-hook="GameCanvas"></canvas>
    """
  end

  @impl true
  def handle_event("toggle_cell", %{"row" => row, "col" => col}, socket) do
    :ok = GameOfLifeWeb.SharedBoard.toggle_cell(row, col)

    {:noreply, socket}
  end
end
