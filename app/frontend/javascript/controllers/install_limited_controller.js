import { Controller } from "@hotwired/stimulus"
import { isiOS, isUserAgentLimited } from "../utils/helpers"

export default class extends Controller {
  static targets = [
    "content"
  ]

  static values = {
    keywords: Array,
    openSafari: String,
    openBrower: String,
  }

  connect() {
    if (!isUserAgentLimited(this.keywordsValue)) { return }

    this.renderInstallLimited()
  }

  renderInstallLimited() {
    if (isiOS()) {
      this.contentTarget.innerText = this.openSafariValue
    } else {
      this.contentTarget.innerText = this.openBrowerValue
    }
    this.element.classList.remove("hidden")
  }
}
