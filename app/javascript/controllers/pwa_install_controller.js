// app/javascript/controllers/pwa_install_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  #deferredPrompt = null

  connect() {
    window.addEventListener("beforeinstallprompt", this.#onPrompt)
    this.#registerSW()
  }

  disconnect() {
    window.removeEventListener("beforeinstallprompt", this.#onPrompt)
  }

  async install() {
    if (!this.#deferredPrompt) return
    this.#deferredPrompt.prompt()
    await this.#deferredPrompt.userChoice
    this.#deferredPrompt = null
  }

  #onPrompt = (event) => {
    event.preventDefault()
    this.#deferredPrompt = event
    const btn = document.getElementById("pwa-install-btn")
    if (btn) btn.hidden = false
  }

  #registerSW() {
    if ("serviceWorker" in navigator) {
      navigator.serviceWorker.register("/sw.js")
    }
  }
}
