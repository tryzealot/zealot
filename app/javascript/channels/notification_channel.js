import consumer from "./consumer"
import { Zealot } from "../controllers/zealot"

const notificationChannel = consumer.subscriptions.create("NotificationChannel", {
  received(data) {
    if (Zealot.isDevelopment) {
      console.debug("Received data", data)
    }

    if (Object.keys(data).length === 0) { return }

    var color = "success"
    var icon = "fa-check"
    if (data.status !== "success") {
      icon = "fa-exclamation-triangle"
      color = "danger"
    }

    const body = document.createElement("div")
    const bodyIcon = document.createElement("i")
    bodyIcon.classList.add("flex-shrink-0", "me-2", "fas", `fas-${icon}`)
    body.appendChild(bodyIcon)

    const messageText = document.createTextNode(data.message)
    body.appendChild(messageText)

    const closeButton = document.createElement("button")
    closeButton.classList.add("btn-sm", "btn-close")
    closeButton.setAttribute("data-bs-dismiss", "alert")

    const notificationAlert = document.createElement("div")
    notificationAlert.classList.add("alert", "alert-dismissible", "fade", "show", `alert-${color}`)
    notificationAlert.appendChild(body)
    notificationAlert.appendChild(closeButton)

    const notificationNode = document.getElementById("notifications")
    notificationNode.insertBefore(notificationAlert, notificationNode.firstChild)

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
