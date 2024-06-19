import { Controller } from "@hotwired/stimulus"
import ClipboardJS from "clipboard"
import * as bootstrap from "bootstrap"

export default class extends Controller {
  static targets = [ "source" ]

  copy(event) {
    const button = event.target
    if (!ClipboardJS.isSupported()) {
      button.setAttribute("disabled", true)
      return this.renderUnsupport(button)
    }

    ClipboardJS.copy(this.sourceTarget)

    this.renderSuccess(button)
    this.hideTooltip(button)
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

  hideTooltip(button) {
    const tooltip = new bootstrap.Tooltip(button)
    if (tooltip) {
      tooltip.hide()
      tooltip.disable()
    }
  }
}
