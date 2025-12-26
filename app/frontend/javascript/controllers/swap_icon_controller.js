import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input"]

  sync() {
    if (!this.hasInputTarget) { return }

    this.inputTarget.checked = !this.inputTarget.checked
    this.inputTarget.dispatchEvent(new Event("change", { bubbles: true }))
  }
}
