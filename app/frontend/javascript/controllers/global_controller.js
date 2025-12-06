import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    if (this.isInitialized) { return }

    if (document.readyState === "loading") {
      this.documentReadyHandler ??= this.handleDocumentReady.bind(this)
      document.addEventListener("DOMContentLoaded", this.documentReadyHandler, { once: true })
    } else {
      this.handleDocumentReady()
    }

    this.isInitialized = true
  }

  switchDarkMode() {
    const appearance = this.element.getAttribute("data-theme")
    this.setGoodJobThemeMode(appearance);
  }

  setGoodJobThemeMode(appearance) {
    localStorage.setItem("good_job-theme", appearance);
  }

  handleDocumentReady() {
    try {
      this.switchDarkMode()
    } catch (error) {
      console.error("GlobalController initialization error:", error)
    }
  }
}
