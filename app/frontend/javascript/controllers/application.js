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
// Turbo.config.forms.confirm = confirmModalHandler

// Enable debug mode in development environment
application.debug = Zealot.isDevelopment

// Configure Stimulus development experience
window.Stimulus = application

export { application }
