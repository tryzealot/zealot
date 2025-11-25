import { Controller } from "@hotwired/stimulus"
import { poll } from "../utils"

const RESTART_URI = "/admin/service/restart"
const HEALTH_CHECK_URI = "/admin/service/status"

export default class extends Controller {
  static targets = ["button"]
  static values = {
    restarting: String,
    restarted: String
  }

  async restart() {
    const buttonHTML = this.buttonTarget.innerHTML

    // Update status of button
    this.clearNotifcation()
    this.updateRestaringState()

    // Do restart action
    await this.serviceRestart()
    await this.sleep(2000)

    // Run loop to check service is back online
    const healthCheck = async () => {
      const response = await fetch(HEALTH_CHECK_URI)
      return response && response.status === 200
    }

    const result = await poll({
      fn: healthCheck,
      validate: (online) => !!online,
      interval: 2000
    })

    if (result) {
      this.updateRestartedState()
      await this.sleep(2000)
      window.location.reload()
    }
  }

  serviceRestart() {
    fetch(RESTART_URI, {
        method: "POST"
      })
      .then((response) => response.status === 200)
      .then((result) => {
        return result
      })
      .catch((error) => {
        console.debug("service restart failed", error)
        return false
    })
  }

  clearNotifcation() {
    const notification = document.getElementById("notifications")
    notification.classList.add("fade")
    setTimeout(function() {
      notification.classList.add("d-none")
    }, 300);
  }

  updateRestaringState() {
    this.buttonTarget.classList.replace("bg-success", "bg-warning")
    this.buttonTarget.innerHTML = "<i class='fas fa-spin fa-sync icon'></i>" +
      this.restartingValue
  }

  updateRestartedState() {
    this.buttonTarget.classList.replace("bg-warning", "bg-success")

    this.buttonTarget.innerHTML = "<i class='fas fa-spin fa-sync icon'></i>" +
      this.restartedValue
  }

  sleep(ms) {
    return new Promise((resolve) => setTimeout(resolve, ms))
  }
}
