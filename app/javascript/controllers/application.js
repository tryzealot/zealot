import { Application } from "@hotwired/stimulus"
import CheckboxSelectAll from "@stimulus-components/checkbox-select-all"
import Notification from "@stimulus-components/notification"
import { confirmModalHandler } from "../utils/modal"

const application = Application.start()
application.register("checkbox-select-all", CheckboxSelectAll)
application.register("notification", Notification)

// Configure Stimulus development experience
window.Stimulus = application

// Override Turbo's default confirm dialog
Turbo.config.forms.confirm = confirmModalHandler

export { application }
