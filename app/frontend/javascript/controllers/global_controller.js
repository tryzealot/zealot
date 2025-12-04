import { Controller } from "@hotwired/stimulus"
import * as ActionCable from "@rails/actioncable"
import { Zealot } from "./zealot"
import { application } from "./application"

export default class extends Controller {
  static values = {
    env: String,
    rootUrl: String,
    appearance: String
  }

  connect() {
    if (this.isInitialized) {
      return
    }

    try {
      this.initZealot()
      this.switchDarkMode()
      this.isInitialized = true
    } catch (error) {
      console.error('GlobalController initialization error:', error)
    }
  }

  initZealot() {
    Zealot.rootUrl = this.rootUrlValue
    Zealot.siteApperance = this.appearanceValue
    Zealot.env = this.envValue
  }

  switchDarkMode() {
    const appearance = Zealot.siteApperance
    this.setGoodJobThemeMode(appearance);
    if (appearance === "dark" || (appearance === "auto" && Zealot.isDarkMode())) {
      document.documentElement.setAttribute("data-bs-theme", "dark");
    } else if (appearance === "light" && Zealot.isDarkMode()) {
      var darkBrandImage = document.getElementsByClassName("dark-brand-image")
      Array.prototype.forEach.call(darkBrandImage, (element) => {
        element.remove()
      })
    }
  }

  setGoodJobThemeMode(appearance) {
    localStorage.setItem("good_job-theme", appearance);
  }
}
