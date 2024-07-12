import consumer from "./consumer"
import { Zealot } from "../controllers/zealot"

const notificationChannel = consumer.subscriptions.create("NotificationChannel", {
  received(data) {
    if (Zealot.isDevelopment) {
      console.debug("Received data", data)
    }

    if (Object.keys(data).length === 0) { return }

    var color = "success"
    var icon = "fas fa-check"
    if (data.status !== "success") {
      icon = "fas fa-exclamation-triangle"
      color = "danger"
    }

    const notificationNode = document.getElementById("notifications")
    const newNotification = document.createElement("div");
    newNotification.classList.add("alert", "alert-dismissible", `alert-${color}`)
    newNotification.innerHTML = "<button aria-hidden='true' class='close' data-dismiss='alert'>×</button>" +
      "<h4><i class='icon fas fa-" + icon + "'></i>" +
      "<span id='flash_notice'>" + data.message + "</span></h4 ></div >"

    notificationNode.insertBefore(newNotification, notificationNode.firstChild)

    if (data.refresh_page) {
      setTimeout(() => {
        location.reload()
      }, 2000)
    } else if (data.redirect_page) {
      setTimeout(() => {
        if (window.location.href !== data.redirect_page ) {
          window.location.href = data.redirect_page
        } else {
          location.reload()
        }
      }, 2000)
    }
  }
})

export default notificationChannel
