import { Controller } from "@hotwired/stimulus"
import * as ActionCable from "@rails/actioncable"
import * as bootstrap from "bootstrap"
import { Zealot } from "./zealot"
import { application } from "./application"
import { PushMenu, Defaults } from "admin-lte"

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
      document.documentElement.setAttribute("data-bs-theme", "dark");

      // var mainHeader = document.getElementsByClassName("app-header")
      // Array.prototype.forEach.call(mainHeader, function(element) {
      //   element.classList.replace("navbar-white", "navbar-dark")
      // })

      // var mainSidebar = document.getElementsByClassName("app-sidebar")
      // Array.prototype.forEach.call(mainSidebar, function(element) {
      //   element.classList.replace("sidebar-light-primary", "sidebar-dark-primary")
      // });
    } else if (apperance === "light" && Zealot.isDarkMode()) {

      var darkBrandImage = document.getElementsByClassName("dark-brand-image")
      Array.prototype.forEach.call(darkBrandImage, function(element) {
        element.remove()
      });
    }
  }

  fixAdminlteWithTubros() {
    this.enableTooltips()
    this.fixSidebarResize()
  }

  enableTooltips() {
    const tooltipTriggerList = document.querySelectorAll('[data-bs-toggle="tooltip"]')
    const tooltipList = [...tooltipTriggerList].map(tooltipTriggerEl => new bootstrap.Tooltip(tooltipTriggerEl, {
      placement: "top"
    }))
  }

  fixSidebarResize() {
    const sidebar = document.querySelector(".app-sidebar")
    if (sidebar) {
      window.addEventListener("turbo:load", () => {
        const data = new PushMenu(sidebar, Defaults)
        data.init()
      })
    }
  }

  setupRailsDebugMode() {
    application.debug = Zealot.isDevelopment()
    ActionCable.logger.enabled = Zealot.isDevelopment()
  }
}
