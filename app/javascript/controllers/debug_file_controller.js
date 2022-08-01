import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["source"]

  connect() {
    this.element.style.cursor = "pointer"
  }

  toggle() {
    this.sourceTarget.classList.toggle("d-none")
  }
}