import { Controller } from "@hotwired/stimulus"
import { isiOS, isMacOS, turboStream } from "../utils/helpers"

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
      this.showInstallButton()
      this.hideDownloadButton()
    } else if (isMacOS()) {
      this.showInstallButton()
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
    this.installIssueTarget.classList.remove("hidden")
  }

  showInstallButton() {
    if (this.hasInstallButtonTarget) {
      this.installButtonTarget.classList.remove("hidden")
    }
  }

  hideDownloadButton() {
    if (this.hasDownloadButtonTarget) {
      this.downloadButtonTarget.classList.add("hidden")
    }
  }

  sleep(ms) {
    return new Promise((resolve) => setTimeout(resolve, ms))
  }
}
