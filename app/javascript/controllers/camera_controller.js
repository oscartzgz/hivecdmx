import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "preview"]
  static values  = { recordId: String }

  async capture() {
    const file = this.inputTarget.files[0]
    if (!file) return

    const compressed = await this.#compress(file)
    await this.#upload(compressed)
    this.inputTarget.value = ""
  }

  async #compress(file) {
    return new Promise((resolve, reject) => {
      const reader = new FileReader()
      reader.onload = () => {
        const img = new Image()
        img.onload = () => {
          const maxSize = 900
          const scale   = Math.min(1, maxSize / Math.max(img.width, img.height))
          const canvas  = document.createElement("canvas")
          canvas.width  = Math.round(img.width  * scale)
          canvas.height = Math.round(img.height * scale)
          canvas.getContext("2d").drawImage(img, 0, 0, canvas.width, canvas.height)
          canvas.toBlob(blob => resolve(blob), "image/jpeg", 0.72)
        }
        img.onerror = reject
        img.src = reader.result
      }
      reader.onerror = reject
      reader.readAsDataURL(file)
    })
  }

  async #upload(blob) {
    const form = new FormData()
    form.set("file", blob, `photo-${Date.now()}.jpg`)

    const response = await fetch(`/records/${encodeURIComponent(this.recordIdValue)}/photos`, {
      method: "POST",
      headers: { "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
                 "Accept": "text/vnd.turbo-stream.html" },
      body: form
    })

    const contentType = response.headers.get("content-type") || ""
    if (contentType.includes("turbo-stream")) {
      const html = await response.text()
      Turbo.renderStreamMessage(html)
    }
  }
}
