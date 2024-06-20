import { Controller } from "@hotwired/stimulus"
import * as bootstrap from "bootstrap";
import { isiOS, isMacOS } from "./utils"

const LOADING_TIMEOUT = 8000

export default class extends Controller {
  static targets = [
    "installLimited",
    "buttons",

    "installButton",
    "downloadButton",

    "installIssue",
    "certExpired"
  ]

  static values = {
    installLimited: Array,
    openSafari: String,
    openBrower: String,

    installUrl: String,
    installing: String,
    installed: String
  }

  connect() {
    if (this.isInstallLimited()) {
      return this.renderInstallLimited()
    }

    if (isiOS()) {
      this.showIntallButton()
      this.hideDownloadButton()
    } else if (isMacOS()) {
      this.showIntallButton()
    }
  }

  install(event) {
    this.renderLoading(event.target)

    const link = this.installUrlValue
    console.debug("install url", link)
    window.location.href = link
  }

  showCertExpired() {
    const modalNode = document.getElementById("cert-expired-issues")
    const modal = new bootstrap.Modal(modalNode)
    modal.toggle()
  }

  showQA() {
    const modalNode = document.getElementById("install-issues")
    const modal = new bootstrap.Modal(modalNode)
    modal.toggle()
  }

  async renderLoading(target) {
    target.innerHTML = this.installingValue
    await this.sleep(LOADING_TIMEOUT)
    target.innerHTML = this.installedValue
    this.installIssueTarget.classList.remove("d-none")
  }

  showIntallButton() {
    if (this.hasInstallButtonTarget) {
      this.installButtonTarget.classList.remove("d-none")
    }
  }

  hideDownloadButton() {
    if (this.hasDownloadButtonTarget) {
      this.downloadButtonTarget.classList.add("d-none")
    }
  }

  renderInstallLimited() {
    let textNode = this.installLimitedTarget.getElementsByClassName("text")[0]
    let brNode = document.createElement("br")
    textNode.appendChild(brNode)
    if (isiOS) {
      textNode.appendChild(document.createTextNode(this.openSafariValue))
    } else {
      textNode.appendChild(document.createTextNode(this.openBrowerValue))
    }

    this.installLimitedTarget.classList.remove("d-none")
    this.buttonsTarget.classList.add("d-none")
  }

  isInstallLimited() {
    let ua = navigator.userAgent
    let matches = this.installLimitedValue.find(keyword => ua.includes(keyword))

    return !!matches
  }

  sleep(ms) {
    return new Promise((resolve) => setTimeout(resolve, ms))
  }
}
