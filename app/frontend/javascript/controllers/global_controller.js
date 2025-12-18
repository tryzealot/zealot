import { Controller } from "@hotwired/stimulus"
import { Zealot } from "./zealot"

const DRAWER_STATUS_KEY = "zealot-drawer-status"
const DRAWER_OPEN_VALUE = "open"
const DRAWER_CLOSED_VALUE = "closed"

export default class extends Controller {
  static targets = ["drawer"]
  
  static values = {
    appearance: String,
    themes: Object
  }

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
    if (!appearance) { return }

    this.setZealotThemeMode()
    this.setGoodJobThemeMode()
  }

  setZealotThemeMode() {
    const appearance = this.appearanceValue
    const lightTheme = this.themesValue.light
    const darkTheme = this.themesValue.dark

    console.log(this.themesValue)

    Zealot.log(`Switching to theme: ${appearance}, light: ${lightTheme}, dark: ${darkTheme}`)

    if (appearance === "auto") {
      this.element.setAttribute("data-theme", Zealot.isDarkMode ? darkTheme : lightTheme)
    } else if (appearance === 'dark') {
      this.element.setAttribute("data-theme", darkTheme)
    } else if (appearance === 'light') {
      this.element.setAttribute("data-theme", lightTheme)
    } else {
      console.log("Unknown appearance mode:", appearance)
    }
  }

  setGoodJobThemeMode() {
    localStorage.setItem("good_job-theme", this.appearanceValue)
  }

  handleDocumentReady() {
    try {
      this.switchDarkMode()
    } catch (error) {
      console.error("GlobalController initialization error:", error)
    }
  }

  switchDrawer() {
    const storedStatus = this.getDrawerStatus()
    const isDrawerOpen = storedStatus === DRAWER_OPEN_VALUE
    this.drawerTarget.checked = isDrawerOpen
  }

  storeDrawerStatus() {
    const isDrawerOpen = this.drawerTarget.checked;
    const value = isDrawerOpen ? DRAWER_OPEN_VALUE : DRAWER_CLOSED_VALUE
    this.setDrawerStatus(value)
  }

  setDrawerStatus(value) {
    localStorage.setItem(DRAWER_STATUS_KEY, value)
    document.cookie = `${DRAWER_STATUS_KEY}=${value}; path=/; max-age=31536000; SameSite=Lax`
  }

  getDrawerStatus() {
    const local = localStorage.getItem(DRAWER_STATUS_KEY)
    if (local) { return local }
    
    const cookie = document.cookie
      .split("; ")
      .find((row) => row.startsWith(`${DRAWER_STATUS_KEY}=`))
    return cookie ? cookie.split("=")[1] : DRAWER_OPEN_VALUE
  }
}
