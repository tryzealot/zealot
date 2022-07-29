import { Controller } from "@hotwired/stimulus"
import Zealot from "../zealot"
import JQuery from "jquery"

const RESTART_URI = "admin/service/restart"
const HEALTH_CHECK_URI = "admin/service/status"

export default class extends Controller {
  static targets = ["button"]
  static values = {
    restarting: String,
    restarted: String
  }

  async restart() {
    const buttonHTML = this.buttonTarget.innerHTML

    this.clearNotifcation()
    this.updateRestaringState()

    var serverRestarting = true;
    const restartSuccess = await this.serviceRestart()
    await this.sleep(2000)

    if (!restartSuccess) {
      this.buttonTarget.innerHTML = buttonHTML
      return false
    }

    do {
      var online = await this.serviceisOnline();
      if (online) {
        serverRestarting = false;
      } else {
        await sleep(1000)
      }
    } while (serverRestarting)

    this.updateRestartedState()
    await this.sleep(2000)
    window.location.reload()
  }

  serviceRestart() {
    try {
      fetch(Zealot.rootUrl + RESTART_URI, {
        method: "POST"
      })
      return true
    } catch (error) {
      return false
    }
  }

  serviceisOnline() {
    try {
      fetch(Zealot.rootUrl + HEALTH_CHECK_URI, {
        method: "GET"
      })
      return true
    } catch (error) {
      return false
    }
  }

  clearNotifcation() {
    JQuery("#notifications").fadeOut();
  }

  updateRestaringState() {
    this.buttonTarget.classList.replace("bg-success", "bg-warning")
    this.buttonTarget.innerHTML = "<i class='fas fa-spin fa-sync'></i>" +
      this.restartingValue
  }

  updateRestartedState() {
    this.buttonTarget.classList.replace("bg-warning", "bg-success")

    this.buttonTarget.innerHTML = "<i class='fas fa-spin fa-sync'></i>" +
      this.restartedValue
  }

  sleep(ms) {
    return new Promise((resolve) => setTimeout(resolve, ms))
  }
}