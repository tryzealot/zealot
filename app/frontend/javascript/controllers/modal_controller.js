import { Controller } from "@hotwired/stimulus"
import { Modal } from "bootstrap"

// Connects to data-controller="modal"
export default class extends Controller {
  connect() {
    this.modal = new Modal(this.element)
    this.modal.show()
  }

  disconnect() {
    this.clear()
  }

  close() {
    this.clear()
  }

  clear() {
    this.modal.hide()
    this.element.remove()
  }
}
