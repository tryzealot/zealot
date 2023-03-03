import { Controller } from "@hotwired/stimulus"
import * as ActionCable from '@rails/actioncable'
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
    this.setupRailsDebugMode()
    this.fixAdminlteWithTubros()
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
      document.body.classList.add("dark-mode")

      jquery(".main-header").addClass("navbar-dark").removeClass("navbar-white")
      jquery(".main-sidebar").addClass("sidebar-dark-primary").removeClass("sidebar-light-primary")

      // document.getElementsByClassName('main-header').classList.replace("navbar-white", "navbar-dark")
      // document.getElementsByClassName('main-sidebar').classList.replace("sidebar-light-primary", "sidebar-dark-primary")
    }
  }

  fixAdminlteWithTubros() {
    this.fixTooltipToggle()
    this.fixSidebarResize()
  }

  fixTooltipToggle() {
    jquery("[data-toggle='tooltip']").tooltip()
  }

  fixSidebarResize() {
    jquery(window).trigger("resize")
  }

  setupRailsDebugMode() {
    application.debug = Zealot.isDevelopment()
    ActionCable.logger.enabled = Zealot.isDevelopment()
  }
}
