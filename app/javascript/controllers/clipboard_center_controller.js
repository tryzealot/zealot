import { Controller } from "@hotwired/stimulus"
import ClipboardJS from "clipboard"
import * as bootstrap from "bootstrap"

export default class extends Controller {
  static targets = [ "source", "button" ]

  copy() {
    this.hideTooltip()
    if (!ClipboardJS.isSupported()) {
      this.buttonTarget.setAttribute("disabled", true)
      return this.renderUnsupport()
    }

    ClipboardJS.copy(this.sourceTarget)

    this.renderSuccess()
  }

  renderUnsupport() {
    this.buttonTarget.classList.add("btn-warning")
    this.buttonTarget.classList.remove("btn-primary")
    const icon = this.buttonTarget.querySelector("i");

    if (icon) {
      icon.classList.add("fa-tired");
      icon.classList.remove("fa-clipboard");
    }
  }

  renderSuccess() {
    this.buttonTarget.classList.add("btn-success")
    this.buttonTarget.classList.remove("btn-primary")
    const icon = this.buttonTarget.querySelector("i");

    if (icon) {
      icon.classList.add("fa-thumbs-up");
      icon.classList.remove("fa-clipboard");
    }
  }

  hideTooltip() {
    const tooltip = new bootstrap.Tooltip(this.buttonTarget)
    if (tooltip) {
      tooltip.hide()
      tooltip.disable()
    }
  }
}
