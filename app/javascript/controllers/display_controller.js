import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["element"]

  toggle() {
    this.elementTarget.classList.toggle("d-none")
  }
}