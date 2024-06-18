import { Controller } from "@hotwired/stimulus"
// import jquery from "jquery"
import ClipboardJS from "clipboard"

export default class extends Controller {
  static targets = [ "source", "button" ]

  copy() {
    this.hideTooltip()
    if (!ClipboardJS.isSupported()) {
      this.button.attr("disabled", true)
      return this.renderUnsupport()
    }

    ClipboardJS.copy(this.sourceTarget)

    this.renderSuccess()
  }

  renderUnsupport() {
    this.button.addClass("btn-warning")
      .removeClass("btn-primary")

    this.button.find("i")
      .addClass("fa-tired")
      .removeClass("fa-clipboard")
  }

  renderSuccess() {
    this.button.addClass("btn-success")
      .removeClass("btn-primary")

    this.button.find("i")
      .addClass("fa-thumbs-up")
      .removeClass("fa-clipboard")
  }

  hideTooltip() {
    this.button.tooltip("hide")
    this.button.tooltip("disable")
  }

  get button() {
    // return jquery(this.buttonTarget)
  }
}
