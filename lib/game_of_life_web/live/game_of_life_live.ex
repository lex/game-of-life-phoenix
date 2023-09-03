defmodule GameOfLifeWeb.GameOfLifeLive do
  use GameOfLifeWeb, :live_view

  # milliseconds
  @tick_rate 33
  @board_rows 32
  @board_cols 32

  @impl true
  def mount(_params, _session, socket) do
    board = GameOfLifeWeb.Board.new(@board_rows, @board_cols)
    send(self(), :tick)
    {:ok, assign(socket, board: board)}
  end

  @impl true
  def handle_info(:tick, socket) do
    new_board = GameOfLifeWeb.Game.step(socket.assigns.board)
    Process.send_after(self(), :tick, @tick_rate)
    {:noreply, assign(socket, board: new_board)}
  end

  @impl true
  def render(assigns) do
    ~L"""
    <div>
      <%= for row <- @board do %>
        <div class="row">
          <%= for cell <- row do %>
            <div class="cell <%= if cell == :alive, do: "alive", else: "dead" %>"></div>
          <% end %>
        </div>
      <% end %>
    </div>
    """
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
