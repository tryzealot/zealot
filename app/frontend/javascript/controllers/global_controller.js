import { Controller } from "@hotwired/stimulus"
import { Zealot } from "./zealot.js"

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

    const documentReadyHandler = this.handleDocumentReady.bind(this)
    document.addEventListener("turbo:load", documentReadyHandler)

    this.isInitialized = true
  }

  previewTheme(event) {
    const theme = event.target.value
    Zealot.log("Previewing theme:", theme)
    if (theme) {
      document.documentElement.setAttribute("data-theme", theme)
      document.body.setAttribute("data-theme", theme)
    }
  }

  switchAppearanceMode() {
    const appearance = document.documentElement.getAttribute("data-theme")
    if (!appearance) { return }

    this.setZealotThemeMode()
    this.setGoodJobThemeMode()
  }

  setZealotThemeMode() {
    const appearance = this.appearanceValue
    const lightTheme = this.themesValue.light
    const darkTheme = this.themesValue.dark

    Zealot.log(`Fetching theme: ${appearance}, light: ${lightTheme}, dark: ${darkTheme}`)
    let activeTheme = null
    if (appearance === "auto") {
      activeTheme = Zealot.isDarkMode ? darkTheme : lightTheme
    } else if (appearance === 'dark') {
      activeTheme = darkTheme
    } else if (appearance === 'light') {
      activeTheme = lightTheme
    } 

    if (activeTheme) {
      Zealot.log(`Setting theme to: ${activeTheme}`)
      document.documentElement.setAttribute("data-theme", activeTheme)
      document.body.setAttribute("data-theme", activeTheme)
    } else {
      console.log("Unknown appearance mode:", appearance)
    }
  }

  setGoodJobThemeMode() {
    localStorage.setItem("good_job-theme", this.appearanceValue)
  }

  handleDocumentReady() {
    try {
      this.switchAppearanceMode()
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
