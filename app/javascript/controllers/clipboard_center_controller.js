import { Controller } from "@hotwired/stimulus"
import ClipboardJS from "clipboard"
import * as bootstrap from "bootstrap"

export default class extends Controller {
  static targets = [ "source" ]

  copy(event) {
    event.preventDefault()
    const button = event.target
    if (!ClipboardJS.isSupported()) {
      button.setAttribute("disabled", true)
      return this.renderUnsupport(button)
    }

    ClipboardJS.copy(this.sourceTarget)

    this.renderSuccess(button)
    this.showTooltip(button)
  }

  renderNormal(button) {
    button.classList.add("btn-primary")
    button.classList.remove("btn-success", "btn-warning")

    const icon = button.querySelector("i")
    if (icon) {
      icon.classList.add("fa-clipboard")
      icon.classList.remove("fa-tired", "fa-thumbs-up")
    }
  }

  renderUnsupport(button) {
    button.classList.add("btn-warning")
    button.classList.remove("btn-primary")

    const icon = button.querySelector("i")
    if (icon) {
      icon.classList.add("fa-tired")
      icon.classList.remove("fa-clipboard")
    }
  }

  renderSuccess(button) {
    button.classList.add("btn-success")
    button.classList.remove("btn-primary")

    const icon = button.querySelector("i")
    if (icon) {
      icon.classList.add("fa-thumbs-up")
      icon.classList.remove("fa-clipboard")
    }
  }

  async showTooltip(button) {
    const tooltip = new bootstrap.Tooltip(button)
    if (tooltip) {
      await this.sleep(3000)
      this.renderNormal(button)
    }
  }

  sleep(ms) {
    return new Promise((resolve) => setTimeout(resolve, ms))
  }
}
