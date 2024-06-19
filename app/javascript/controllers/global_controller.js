import { Controller } from "@hotwired/stimulus"
import * as ActionCable from "@rails/actioncable"
import { Zealot } from "./zealot"
import { application } from "./application"

export default class extends Controller {
  static values = {
    env: String,
    rootUrl: String,
    apperance: String
  }

  connect() {
    this.initZealot()
    this.setupRailsDebugMode()
    this.switchDarkMode()
  }

  initZealot() {
    Zealot.rootUrl = this.rootUrlValue
    Zealot.siteApperance = this.apperanceValue
    Zealot.env = this.envValue
  }

  switchDarkMode() {
    const apperance = Zealot.siteApperance
    if (apperance === "dark" || (apperance === "auto" && Zealot.isDarkMode())) {
      document.documentElement.setAttribute("data-bs-theme", "dark");
    } else if (apperance === "light" && Zealot.isDarkMode()) {
      var darkBrandImage = document.getElementsByClassName("dark-brand-image")
      darkBrandImage.forEach((element) => {
        element.remove()
      })
    }
  }

  setupRailsDebugMode() {
    application.debug = Zealot.isDevelopment()
    ActionCable.logger.enabled = Zealot.isDevelopment()
  }
}
