import { Application } from "@hotwired/stimulus"
import CheckboxSelectAll from "@stimulus-components/checkbox-select-all"

const application = Application.start()
application.register("checkbox-select-all", CheckboxSelectAll)

// Configure Stimulus development experience
window.Stimulus = application

export { application }
