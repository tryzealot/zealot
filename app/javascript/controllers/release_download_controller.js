import { Controller } from "@hotwired/stimulus"
import { isiOS, isMacOS, turboStream } from "./utils"

const LOADING_TIMEOUT = 8000

export default class extends Controller {
  static targets = [
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
    turboStream("/modals/cert-expired-issues")
  }

  showQA() {
    turboStream("/modals/install-issue")
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

  sleep(ms) {
    return new Promise((resolve) => setTimeout(resolve, ms))
  }
}
