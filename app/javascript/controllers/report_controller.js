// app/javascript/controllers/report_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { room: String, date: String }

  async share() {
    const text = this.#buildText()
    if (navigator.share) {
      await navigator.share({ title: "Reporte diario Hive", text })
    } else {
      location.href = `mailto:?subject=${encodeURIComponent("Reporte diario Hive")}&body=${encodeURIComponent(text)}`
    }
  }

  #buildText() {
    const items = [...document.querySelectorAll("[data-defective-item]")]
    const lines = [
      "REPORTE DIARIO — HIVE CENTRO HISTÓRICO",
      `Fecha: ${this.dateValue}`,
      `Habitación: ${this.roomValue}`,
      ""
    ]
    items.forEach(el => lines.push(`- ${el.textContent.trim()}`))
    return lines.join("\n")
  }
}
