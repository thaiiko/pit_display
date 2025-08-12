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
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"
import SaladUI from "./ui/index.js";
import "./ui/components/dialog.js";
import "./ui/components/select.js";
import "./ui/components/tabs.js";
import "./ui/components/radio_group.js";
import "./ui/components/popover.js";
import "./ui/components/hover-card.js";
import "./ui/components/collapsible.js";
import "./ui/components/tooltip.js";
import "./ui/components/accordion.js";
import "./ui/components/slider.js";
import "./ui/components/switch.js";
import "./ui/components/dropdown_menu.js";

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: {_csrf_token: csrfToken},
  hooks: { SaladUI: SaladUI.SaladUIHook }
});

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

window.addEventListener('mousemove', e => {
  const dotGrid = document.querySelector('.bg-dot-grid');
  if (dotGrid) {
    const x = e.clientX / window.innerWidth;
    const y = e.clientY / window.innerHeight;
    dotGrid.style.backgroundPosition = `-${x * 30}px -${y * 30}px`;
  }
});
