import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="modal"
export default class extends Controller {
  connect() {
    this.element.showModal()
  }

  disconnect() {
    this.clear()
  }

  close(event) {
    if (event?.detail && !event.detail.success) {
      return
    }

    this.clear()
  }

  clear() {
    // this.modal.hide()
    this.element.remove()
  }
}
