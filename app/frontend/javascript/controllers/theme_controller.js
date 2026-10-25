import { Controller } from "@hotwired/stimulus"
import { Zealot } from "./zealot"

export default class extends Controller {
  static values = {
    appearance: String,
    themes: Object
  }

  initialize() {
    this.setupColorSchemeQuery()
  }

  connect() {
    this.setupColorSchemeQuery()
    this.colorSchemeQuery.addEventListener("change", this.boundColorSchemeChange)
    this.applyTheme()
  }

  setupColorSchemeQuery() {
    this.colorSchemeQuery ??= window.matchMedia("(prefers-color-scheme: dark)")
    this.boundColorSchemeChange ??= this.handleColorSchemeChange.bind(this)
  }

  disconnect() {
    this.colorSchemeQuery.removeEventListener("change", this.boundColorSchemeChange)
  }

  appearanceValueChanged() {
    this.applyTheme()
  }

  handleColorSchemeChange() {
    if (this.appearanceValue === "auto") {
      this.applyTheme()
    }
  }

  applyTheme() {
    this.setZealotThemeMode()
    this.setGoodJobThemeMode()
  }

  setZealotThemeMode() {
    const appearance = this.appearanceValue
    const lightTheme = this.themesValue?.light
    const darkTheme = this.themesValue?.dark

    Zealot.log(`Fetching theme: ${appearance}, light: ${lightTheme}, dark: ${darkTheme}`)
    let activeTheme = null
    if (appearance === "auto") {
      activeTheme = Zealot.isDarkMode ? darkTheme : lightTheme
    } else if (appearance === "dark") {
      activeTheme = darkTheme
    } else if (appearance === "light") {
      activeTheme = lightTheme
    }

    if (activeTheme) {
      Zealot.log(`Setting theme to: ${activeTheme}`)
      document.documentElement.setAttribute("data-theme", activeTheme)
    }
  }

  setGoodJobThemeMode() {
    const appearance = this.appearanceValue
    const theme = appearance === "auto"
      ? (Zealot.isDarkMode ? "dark" : "light")
      : appearance

    Zealot.log(`Setting good_job theme to: ${theme}`)
    try {
      localStorage.setItem("good_job-theme", theme)
    } catch (_) {}

    this.syncGoodJobDashboard(theme)
  }

  syncGoodJobDashboard(theme) {
    this.element.querySelectorAll("iframe").forEach((frame) => {
      let doc
      try {
        doc = frame.contentDocument
      } catch (_) {
        return // cross-origin iframe
      }

      if (!doc || doc.readyState !== "complete") {
        return // not loaded yet, it will read `good_job-theme` itself
      }

      const button = doc.querySelector(`[data-theme-value-param="${theme}"]`)
      if (button) {
        button.click()
      }
    })
  }

  previewTheme(event) {
    const theme = event.target.value
    Zealot.log("Previewing theme:", theme)
    if (theme) {
      document.documentElement.setAttribute("data-theme", theme)
    }
  }
}
