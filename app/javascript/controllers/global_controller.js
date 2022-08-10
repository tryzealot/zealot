import { Controller } from "@hotwired/stimulus"
import { Zealot } from "./zealot"
import { application } from "./application"
import jquery from "jquery"

export default class extends Controller {
  static values = {
    env: String,
    rootUrl: String,
    apperance: String
  }

  connect() {
    this.initZealot()
    this.fixAdminlteWithTubros()
    this.switchDarkMode()
  }

  initZealot() {
    Zealot.rootUrl = this.rootUrlValue
    Zealot.siteApperance = this.apperanceValue
    Zealot.env = this.envValue
    application.debug = Zealot.isDevelopment()
  }

  switchDarkMode() {
    const apperance = Zealot.siteApperance
    if (apperance === "dark" || (apperance === "auto" && Zealot.isDarkMode())) {
      document.body.classList.add("dark-mode")

      jquery(".main-header").addClass("navbar-dark").removeClass("navbar-white")
      jquery(".main-sidebar").addClass("sidebar-dark-primary").removeClass("sidebar-light-primary")

      // document.getElementsByClassName('main-header').classList.replace("navbar-white", "navbar-dark")
      // document.getElementsByClassName('main-sidebar').classList.replace("sidebar-light-primary", "sidebar-dark-primary")
    }
  }

  fixAdminlteWithTubros() {
    this.fixTooltipToggle()
  }

  fixTooltipToggle() {
    jquery("[data-toggle='tooltip']").tooltip()
  }
}