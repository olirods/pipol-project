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
import Chart from 'chart.js/auto';

let hooks = {}
hooks.ChartJS =  {
  labels() { return JSON.parse(this.el.dataset.labels); },
  dataset() { return JSON.parse(this.el.dataset.points); },
  mounted() {
    const ctx = this.el;
  const data = {
      type: 'line',
      data: {
        // random data to validate chart generation
        labels: this.labels(),
        datasets: [{data: this.dataset()}]
      },
      options: {
        maintainAspectRatio: false,
        plugins: {
          legend: {display: false}
        }
      },
  };
    const chart = new Chart(ctx, data);
  }
} 

hooks.Gallery = {
  nextImage(galleryId) {
    const galleryElement = document.querySelector(`#${galleryId}`);
    const images = JSON.parse(galleryElement.dataset.images);
    const imgElement = document.querySelector(`#${galleryId}-image`);
    const currentSrc = imgElement.src;
    const currentIndex = images.indexOf(currentSrc);
    const nextIndex = (currentIndex + 1) % images.length;
    imgElement.src = images[nextIndex];
  },
  prevImage(galleryId) {
    const galleryElement = document.querySelector(`#${galleryId}`);
    const images = JSON.parse(galleryElement.dataset.images);
    const imgElement = document.querySelector(`#${galleryId}-image`);
    const currentSrc = imgElement.src;
    const currentIndex = images.indexOf(currentSrc);
    const prevIndex = (currentIndex - 1 + images.length) % images.length;
    imgElement.src = images[prevIndex];
  },
  mounted() {
    document.getElementById("button-prev").onclick = () => this.prevImage(this.el.id);
    document.getElementById("button-next").onclick = () => this.nextImage(this.el.id);
  }
}

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  hooks: hooks,
  params: {_csrf_token: csrfToken}
})

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

