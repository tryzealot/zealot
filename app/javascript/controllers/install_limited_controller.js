import { Controller } from "@hotwired/stimulus"
import { isiOS, isUserAgentLimited } from "./utils"

export default class extends Controller {
  static targets = [
    "modal"
  ]

  static values = {
    keywords: Array,
    openSafari: String,
    openBrower: String,
  }

  connect() {
    if (isUserAgentLimited(this.keywordsValue)) {
      return this.renderInstallLimited()
    }
  }

  renderInstallLimited() {
    let textNode = this.modalTarget.getElementsByClassName("text")[0]
    let brNode = document.createElement("br")
    textNode.appendChild(brNode)
    if (isiOS()) {
      textNode.appendChild(document.createTextNode(this.openSafariValue))
    } else {
      textNode.appendChild(document.createTextNode(this.openBrowerValue))
    }

    this.modalTarget.classList.remove("d-none")
  }
}
