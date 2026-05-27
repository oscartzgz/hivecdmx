import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["query", "card"]

  filter() {
    const query = this.queryTarget.value.trim().toLowerCase()

    this.cardTargets.forEach(card => {
      const text = card.textContent.toLowerCase()
      card.style.display = text.includes(query) ? "" : "none"
    })
  }
}
