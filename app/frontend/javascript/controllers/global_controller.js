import { Controller } from "@hotwired/stimulus"
import { turboStream } from "../utils/helpers"
import { Zealot } from "./zealot"

const DRAWER_OPEN_VALUE = "open"
const DRAWER_CLOSED_VALUE = "closed"

export default class extends Controller {
  static targets = ["drawer"]
  
  static values = {
    drawerStatusKey: String,
    appearance: String,
    themes: Object
  }

  connect() {
    if (this.isInitialized) { return }

    const documentReadyHandler = this.handleDocumentReady.bind(this)
    document.addEventListener("turbo:load", documentReadyHandler)

    // Initialize drawer state
    this.autoSwitchDrawerByDevice()
    window.addEventListener("resize", this.autoSwitchDrawerByDevice.bind(this))

    this.isInitialized = true
  }

  autoSwitchDrawerByDevice() {
    if (!this.hasDrawerTarget) return
    // Tailwind md: 768px, lg: 1024px
    const width = window.innerWidth
    if (width >= 1024) {
      // width above lg, drawer open
      this.drawerTarget.checked = true
      this.setDrawerStatus(DRAWER_OPEN_VALUE)
    } else {
      // else，drawer close
      this.drawerTarget.checked = false
      this.setDrawerStatus(DRAWER_CLOSED_VALUE)
    }
  }

  previewTheme(event) {
    const theme = event.target.value
    Zealot.log("Previewing theme:", theme)
    if (theme) {
      document.documentElement.setAttribute("data-theme", theme)
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
    } else if (appearance === "dark") {
      activeTheme = darkTheme
    } else if (appearance === "light") {
      activeTheme = lightTheme
    } 

    if (activeTheme) {
      Zealot.log(`Setting theme to: ${activeTheme}`)
      document.documentElement.setAttribute("data-theme", activeTheme)
    } else {
      console.log("Unknown appearance mode:", appearance)
    }
  }

  setGoodJobThemeMode() {
    // GoodJob only understands "light"/"dark". Resolve "auto" the same way
    // Zealot does, otherwise GoodJob is left on "auto" while Zealot is already
    // showing the resolved theme.
    const appearance = this.appearanceValue
    const theme = appearance === "auto"
      ? (Zealot.isDarkMode ? "dark" : "light")
      : appearance

    Zealot.log(`Setting good_job theme to: ${theme}`)
    localStorage.setItem("good_job-theme", theme)

    this.syncGoodJobDashboard(theme)
  }

  // The dashboard is embedded in a same-origin <iframe> and bootstraps its
  // theme from `good_job-theme` while this controller is still starting up, so
  // it can load before the key above is written. Push the resolved theme into
  // any dashboard that has already finished loading (identified by its theme
  // buttons, so unrelated iframes are left alone).
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
    localStorage.setItem(this.drawerStatusKeyValue, value)
    document.cookie = `${this.drawerStatusKeyValue}=${value}; path=/; max-age=31536000; SameSite=Lax`
  }

  getDrawerStatus() {
    const local = localStorage.getItem(this.drawerStatusKeyValue)
    if (local) { return local }
    
    const cookie = document.cookie
      .split("; ")
      .find((row) => row.startsWith(`${this.drawerStatusKeyValue}=`))
    return cookie ? cookie.split("=")[1] : DRAWER_OPEN_VALUE
  }

  showSponsorModal() {
    turboStream("/modals/sponsor")
  }
} 
