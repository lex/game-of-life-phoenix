// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html";
// Establish Phoenix Socket and LiveView configuration.
import { Socket } from "phoenix";
import { LiveSocket } from "phoenix_live_view";
import topbar from "../vendor/topbar";

let Hooks = {};
const CELL_SIZE = 20;

Hooks.GameCanvas = {
  mounted() {
    this.handleEvent("renderGame", ({ board }) => {
      this.renderBoard(board);
    });

    // Listen for click events on the canvas
    this.el.addEventListener("click", (event) => this.cellClicked(event));
  },
  renderBoard(board) {
    const canvas = this.el;
    const ctx = canvas.getContext("2d");
    const cellSize = CELL_SIZE;

    // Clear the canvas
    ctx.clearRect(0, 0, canvas.width, canvas.height);

    for (let row = 0; row < board.length; row++) {
      for (let col = 0; col < board[row].length; col++) {
        const cell = board[row][col];

        // Set the cell color based on its state
        ctx.fillStyle = cell === "alive" ? "black" : "white";

        // Draw the cell
        ctx.fillRect(col * cellSize, row * cellSize, cellSize, cellSize);
      }
    }
  },
  cellClicked(event) {
    const cellSize = CELL_SIZE;
    const rect = this.el.getBoundingClientRect();
    const x = event.clientX - rect.left;
    const y = event.clientY - rect.top;
    const row = Math.floor(y / cellSize);
    const col = Math.floor(x / cellSize);

    // Send the "toggle_cell" event to the server with the row and column as arguments
    this.pushEvent("toggle_cell", { row: row, col: col });
  },
};

let csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute("content");
let liveSocket = new LiveSocket("/live", Socket, {
  params: { _csrf_token: csrfToken },
  hooks: Hooks,
});

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" });
window.addEventListener("phx:page-loading-start", (_info) => topbar.show(300));
window.addEventListener("phx:page-loading-stop", (_info) => topbar.hide());

// connect if there are any LiveViews on the page
liveSocket.connect();

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket;
