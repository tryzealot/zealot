import { Application } from "@hotwired/stimulus"
import CheckboxSelectAll from "@stimulus-components/checkbox-select-all"
import Notification from "@stimulus-components/notification"

import { Turbo } from "@hotwired/turbo-rails"
import { confirmModalHandler } from "../utils/modal"

import { Zealot } from "../controllers/zealot"

const application = Application.start()
application.register("checkbox-select-all", CheckboxSelectAll)
application.register("notification", Notification)

// Override Turbo's default confirm dialog
Turbo.config.forms.confirm = confirmModalHandler

// Promote modal frame navigations to full page visits when target frame is not in response (e.g. redirect after creation)
document.addEventListener("turbo:frame-missing", (event) => {
  const { detail: { response, visit } } = event
  if (event.target.id === "modal") {
    event.preventDefault()
    visit(response.url)
  }
})

// Enable debug mode in development environment
application.debug = Zealot.isDevelopment

// Configure Stimulus development experience
window.Stimulus = application

export { application }
