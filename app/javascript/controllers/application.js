import { Application } from "@hotwired/stimulus"

const application = Application.start()

// Configure Stimulus development experience
window.Stimulus   = application

export { application }
