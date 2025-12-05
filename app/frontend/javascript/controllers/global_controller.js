import { Controller } from "@hotwired/stimulus"
import { Zealot } from "./zealot.js"

export default class extends Controller {
  static values = {
    rootUrl: String,
    appearance: String,
    lightTheme: String,
    darkTheme: String
  }

  connect() {
    Zealot.log("appearance:", this.appearanceValue,
      "light:", this.lightThemeValue,
      "dark:", this.darkThemeValue
    )

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
    const appearance = this.appearanceValue
    this.setZealotThemeMode(appearance);
    this.setGoodJobThemeMode(appearance);
  }

  setZealotThemeMode(appearance) {
    if (appearance === "dark" || (appearance === "auto" && Zealot.isDarkMode)) {
      this.setTheme(this.darkThemeValue);
    } else {
      this.setTheme(this.lightThemeValue);

      // set hidden dark theme images if user preference is light
      if (appearance === "light" && Zealot.isDarkMode) {
        var darkBrandImage = document.getElementsByClassName("dark-brand-image")
        Array.prototype.forEach.call(darkBrandImage, (element) => {
          element.classList.add("tw:hidden")
          element.classList.remove("tw:block")
        })
      }
    }
  }

  setTheme(value) {
    document.body.setAttribute("data-theme", value)
  }

  toggleBrandLogo(isDarkMode) {
    var lightBrandImage = document.getElementsByClassName("light-brand-image")
    var darkBrandImage = document.getElementsByClassName("dark-brand-image")
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
